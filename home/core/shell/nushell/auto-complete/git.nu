# https://github.com/nushell/nu_scripts/blob/main/custom-completions/git/git-completions.nu

# nu-version: 0.102.0

module git-completion-utils {
  export const GIT_SKIPABLE_FLAGS = ['-v', '--version', '-h', '--help', '-p', '--paginate', '-P', '--no-pager', '--no-replace-objects', '--bare']

  # 辅助函数：如果 token 非空则追加
  def append-non-empty [token: string]: list<string> -> list<string> {
    if ($token | is-empty) { $in } else { $in | append $token }
  }

  # 将字符串按参数分割，考虑引号
  # 代码来源并修改自 https://github.com/nushell/nushell/issues/14582#issuecomment-2542596272
  export def args-split []: string -> list<string> {
    # 定义状态
    const STATE_NORMAL = 0
    const STATE_IN_SINGLE_QUOTE = 1
    const STATE_IN_DOUBLE_QUOTE = 2
    const STATE_ESCAPE = 3
    const WHITESPACES = [" " "\t" "\n" "\r"]

    # 初始化变量
    mut state = $STATE_NORMAL
    mut current_token = ""
    mut result: list<string> = []
    mut prev_state = $STATE_NORMAL

    # 处理每个字符
    for char in ($in | split chars) {
      if $state == $STATE_ESCAPE {
        # 处理转义字符
        $current_token = $current_token + $char
        $state = $prev_state
      } else if $char == '\' {
        # 进入转义状态
        $prev_state = $state
        $state = $STATE_ESCAPE
      } else if $state == $STATE_NORMAL {
        if $char == "'" {
          $state = $STATE_IN_SINGLE_QUOTE
        } else if $char == '"' {
          $state = $STATE_IN_DOUBLE_QUOTE
        } else if ($char in $WHITESPACES) {
          # 普通状态下的空白字符表示参数边界
          $result = $result | append-non-empty $current_token
          $current_token = ""
        } else {
          $current_token = $current_token + $char
        }
      } else if $state == $STATE_IN_SINGLE_QUOTE {
        if $char == "'" {
          $state = $STATE_NORMAL
        } else {
          $current_token = $current_token + $char
        }
      } else if $state == $STATE_IN_DOUBLE_QUOTE {
        if $char == '"' {
          $state = $STATE_NORMAL
        } else {
          $current_token = $current_token + $char
        }
      }
    }
    # 处理最后一个参数
    $result = $result | append-non-empty $current_token
    # 返回结果
    $result
  }

  # 获取可通过 `git checkout --` 恢复的已更改文件
  export def get-changed-files []: nothing -> list<string> {
    ^git status -uno --porcelain=2 | lines
    | where $it =~ '^1 [.MD]{2}'
    | each { split row ' ' -n 9 | last }
  }

  # 获取可通过 `git checkout <tree-ish>` 检出的文件
  export def get-checkoutable-files []: nothing -> list<string> {
    # 相关状态有 .M", "MM", "MD", ".D", "UU"
    ^git status -uno --porcelain=2 | lines
    | where $it =~ '^1 ([.MD]{2}|UU)'
    | each { split row ' ' -n 9 | last }
  }

  export def get-all-git-local-refs []: nothing -> list<record<ref: string, obj: string, upstream: string, subject: string>> {
    ^git for-each-ref --format '%(refname:lstrip=2)%09%(objectname:short)%09%(upstream:remotename)%(upstream:track)%09%(contents:subject)' refs/heads | lines | parse "{ref}\t{obj}\t{upstream}\t{subject}"
  }

  export def get-all-git-remote-refs []: nothing -> list<record<ref: string, obj: string, subject: string>> {
    ^git for-each-ref --format '%(refname:lstrip=2)%09%(objectname:short)%09%(contents:subject)' refs/remotes | lines | parse "{ref}\t{obj}\t{subject}"
  }

  # 获取可传递给 `git merge` 的本地和远程分支
  export def get-mergable-sources []: nothing -> list<record<value: string, description: string>> {
    let local = get-all-git-local-refs | each {|x| {value: $x.ref description: $'Branch, Local, ($x.obj) ($x.subject), (if ($x.upstream | is-not-empty) { $x.upstream } else { "no upstream" } )'} } | insert style 'light_blue'
    let remote = get-all-git-remote-refs | each {|x| {value: $x.ref description: $'Branch, Remote, ($x.obj) ($x.subject)'} } | insert style 'blue_italic'
    $local | append $remote
  }
}

def "nu-complete git available upstream" [] {
  ^git branch --no-color -a | lines | each { |line| $line | str replace '* ' "" | str trim }
}

def "nu-complete git remotes" [] {
  ^git remote | lines | each { |line| $line | str trim }
}

def "nu-complete git log" [] {
  ^git log --pretty=%h | lines | each { |line| $line | str trim }
}

# 输出所有现有提交，按时间倒序排列。
def "nu-complete git commits all" [] {
  ^git rev-list --all --remotes --pretty=oneline | lines | parse "{value} {description}"
}

# 仅输出当前分支的提交。适用于如 `git rebase` 的分割点。
def "nu-complete git commits current branch" [] {
  ^git log --pretty="%h %s" | lines | parse "{value} {description}"
}

# 输出本地分支，如 `main`、`feature/typo_fix`
def "nu-complete git local branches" [] {
  ^git branch --no-color | lines | each { |line| $line | str replace '* ' "" | str replace '+ ' ""  | str trim }
}

# 输出远程分支，如 `origin/main`、`upstream/feature-a`
def "nu-complete git remote branches with prefix" [] {
  ^git branch --no-color -r | lines | parse -r '^\*?(\s*|\s*\S* -> )(?P<branch>\S*$)' | get branch | uniq
}

# 输出可传递给 `git merge` 的本地和远程分支名
def "nu-complete git mergable sources" [] {
  use git-completion-utils *
  let branches = get-mergable-sources
  {
    options: {
        case_sensitive: false,
        completion_algorithm: prefix,
        sort: false,
    },
    completions: $branches
  }
}

def "nu-complete git switch" [] {
  use git-completion-utils *
  let branches = get-mergable-sources
  {
    options: {
        case_sensitive: false,
        completion_algorithm: prefix,
        sort: false,
    },
    completions: $branches
  }
}

def "nu-complete git checkout" [context: string, position?:int] {
  use git-completion-utils *
  let preceding = $context | str substring ..$position
  # 查看用户之前输入的内容，如 'git checkout a-branch a-path'。
  # 我们从之前的 token 中排除一些标志，以检测第一个参数是否为分支名称。
  # FIXME: 这种方法仍然很简单。
  let prev_tokens = $preceding | str trim | args-split | where ($it not-in $GIT_SKIPABLE_FLAGS)
  # 在以下场景中，我们只建议文件路径，而不是分支：
  # - 在 '--' 之后
  # - 第一个参数是分支
  # 如果 '--' 之前只是 'git checkout'（或其别名），我们只建议“脏”文件（用户即将重置文件）。
  if $prev_tokens.2? == '--' {
    return (get-changed-files)
  }
  if '--' in $prev_tokens {
    return (get-checkoutable-files)
  }
  # 已经输入了第一个参数。
  if ($prev_tokens | length) > 2 and $preceding ends-with ' ' {
    return (get-checkoutable-files)
  }
  # 第一个参数可以是本地分支、远程分支、文件和提交
  # 获取本地和远程分支
  let branches = get-mergable-sources
  let files = (get-checkoutable-files) | wrap value | insert description '文件' | insert style green
  let commits = ^git rev-list -n 400 --remotes --oneline | lines | split column -n 2 ' ' value description | upsert description {|x| $'提交, ($x.value) ($x.description)' } | insert style 'light_cyan_dimmed'
  {
    options: {
        case_sensitive: false,
        completion_algorithm: prefix,
        sort: false,
    },
    completions: [...$branches, ...$files, ...$commits]
  }
}

# `git rebase --onto <arg1> <arg2>` 的参数
def "nu-complete git rebase" [] {
  (nu-complete git local branches)
  | parse "{value}"
  | insert description "本地分支"
  | append (nu-complete git remote branches with prefix
            | parse "{value}"
            | insert description "远程分支")
  | append (nu-complete git commits all)
}

def "nu-complete git stash-list" [] {
  git stash list | lines | parse "{value}: {description}"
}

def "nu-complete git tags" [] {
  ^git tag --no-color | lines
}

# `man git-status` 中 "Short Format" 的说明
# 这不是全部，但应覆盖最常见的情况。
const short_status_descriptions = {
  ".D": "已删除"
  ".M": "已修改"
  "!" : "已忽略"
  "?" : "未跟踪"
  "AU": "已暂存，未合并"
  "MD": "部分修改已暂存，工作区文件已删除"
  "MM": "部分修改已暂存，部分修改未跟踪"
  "R.": "已重命名"
  "UU": "双方均已修改（合并冲突）"
}

def "nu-complete git files" [] {
  let relevant_statuses = ["?",".M", "MM", "MD", ".D", "UU"]
  ^git status -uall --porcelain=2
  | lines
  | each { |$it|
    if $it starts-with "1 " {
      $it | parse --regex "1 (?P<short_status>\\S+) (?:\\S+\\s?){6} (?P<value>\\S+)"
    } else if $it starts-with "2 " {
      $it | parse --regex "2 (?P<short_status>\\S+) (?:\\S+\\s?){6} (?P<value>\\S+)"
    } else if $it starts-with "u " {
      $it | parse --regex "u (?P<short_status>\\S+) (?:\\S+\\s?){8} (?P<value>\\S+)"
    } else if $it starts-with "? " {
      $it | parse --regex "(?P<short_status>.{1}) (?P<value>.+)"
    } else {
      { short_status: 'unknown', value: $it }
    }
  }
  | flatten
  | where $it.short_status in $relevant_statuses
  | insert "description" { |e| $short_status_descriptions | get $e.short_status}
}

def "nu-complete git built-in-refs" [] {
  [HEAD FETCH_HEAD ORIG_HEAD]
}

def "nu-complete git refs" [] {
  nu-complete git local branches
  | parse "{value}"
  | insert description "分支"
  | append (nu-complete git tags | parse "{value}" | insert description "标签")
  | append (nu-complete git built-in-refs)
}

def "nu-complete git files-or-refs" [] {
  nu-complete git local branches
  | parse "{value}"
  | insert description "分支"
  | append (nu-complete git files | where description == "已修改" | select value)
  | append (nu-complete git tags | parse "{value}" | insert description "标签")
  | append (nu-complete git built-in-refs)
}

def "nu-complete git subcommands" [] {
  ^git help -a | lines | where $it starts-with "   " | parse -r '\s*(?P<value>[^ ]+) \s*(?P<description>\w.*)'
}

def "nu-complete git add" [] {
  nu-complete git files
}

def "nu-complete git pull rebase" [] {
  ["false","true","merges","interactive"]
}

def "nu-complete git merge strategies" [] {
  ['ort', 'octopus']
}

def "nu-complete git merge strategy options" [] {
  ['ours', 'theirs']
}


# 检出 git 分支和文件
export extern "git checkout" [
  ...targets: string@"nu-complete git checkout"   # 要检出的分支或文件的名称
  --conflict: string                              # 冲突样式（merge 或 diff3）
  --detach(-d)                                    # 在指定提交处分离 HEAD
  --force(-f)                                     # 强制检出（丢弃本地修改）
  --guess                                         # 第二次猜测 'git checkout <no-such-branch>'（默认）
  --ignore-other-worktrees                        # 不检查其他工作树是否持有给定的引用
  --ignore-skip-worktree-bits                     # 不仅限于稀疏条目的路径规范
  --merge(-m)                                     # 与新分支进行三方合并
  --orphan: string                                # 新的无父分支
  --ours(-2)                                      # 检出未合并文件的我们的版本
  --overlay                                       # 使用覆盖模式（默认）
  --overwrite-ignore                              # 更新被忽略的文件（默认）
  --patch(-p)                                     # 交互选择块
  --pathspec-from-file: string                    # 从文件中读取路径规范
  --progress                                      # 强制进度报告
  --quiet(-q)                                     # 抑制进度报告
  --recurse-submodules                            # 控制子模块的递归更新
  --theirs(-3)                                    # 检出未合并文件的他们的版本
  --track(-t)                                     # 为新分支设置上游信息
  -b                                              # 创建并检出新分支
  -B: string                                      # 创建/重置并检出分支
  -l                                              # 为新分支创建 reflog
]

export extern "git reset" [
  ...targets: string@"nu-complete git checkout"      # 要重置到的提交、分支或文件的名称
  --hard                                          # 重置 HEAD、索引和工作树
  --keep                                          # 重置 HEAD 但保留本地更改
  --merge                                         # 重置 HEAD、索引和工作树
  --mixed                                         # 重置 HEAD 和索引
  --patch(-p)                                     # 交互选择块
  --quiet(-q)                                     # 安静，只报告错误
  --soft                                          # 仅重置 HEAD
  --pathspec-from-file: string                    # 从文件中读取路径规范
  --pathspec-file-nul                             # 使用 NUL 字符分隔路径规范元素
  --no-refresh                                    # 重置后跳过刷新索引
  --recurse-submodules: string                    # 控制子模块的递归更新
  --no-recurse-submodules                         # 不递归到子模块
]

# 从另一个存储库下载对象和引用
export extern "git fetch" [
  repository?: string@"nu-complete git remotes" # 要获取的分支名称
  --all                                         # 获取所有远程
  --append(-a)                                  # 将引用名称和对象名称附加到 .git/FETCH_HEAD
  --atomic                                      # 使用原子事务更新本地引用。
  --depth: int                                  # 将获取限制为从顶端的 n 次提交
  --deepen: int                                 # 将获取限制为从当前浅边界的 n 次提交
  --shallow-since: string                       # 按日期加深或缩短历史记录
  --shallow-exclude: string                     # 按分支/标签加深或缩短历史记录
  --unshallow                                   # 获取所有可用历史记录
  --update-shallow                              # 更新 .git/shallow 以接受新引用
  --negotiation-tip: string                     # 指定获取时要报告的提交/全局
  --negotiate-only                              # 不获取，只打印共同祖先
  --dry-run                                     # 显示将要做的事情
  --write-fetch-head                            # 在 FETCH_HEAD 中写入获取的引用（默认）
  --no-write-fetch-head                         # 不写入 FETCH_HEAD
  --force(-f)                                   # 始终更新本地分支
  --keep(-k)                                    # 保留下载的包
  --multiple                                    # 允许指定多个参数
  --auto-maintenance                            # 在结束时运行 'git maintenance run --auto'（默认）
  --no-auto-maintenance                         # 在结束时不运行 'git maintenance'
  --auto-gc                                     # 在结束时运行 'git maintenance run --auto'（默认）
  --no-auto-gc                                  # 在结束时不运行 'git maintenance'
  --write-commit-graph                          # 获取后写入提交图
  --no-write-commit-graph                       # 获取后不写入提交图
  --prefetch                                    # 将所有引用放入 refs/prefetch/ 命名空间
  --prune(-p)                                   # 删除过时的远程跟踪引用
  --prune-tags(-P)                              # 删除本地不存在于远程的标签
  --no-tags(-n)                                 # 禁用自动标签跟踪
  --refmap: string                              # 使用此引用规范将引用映射到远程跟踪分支
  --tags(-t)                                    # 获取所有标签
  --recurse-submodules: string                  # 获取已填充子模块的新提交（是/按需/否）
  --jobs(-j): int                               # 并行子进程数
  --no-recurse-submodules                       # 禁用子模块的递归获取
  --set-upstream                                # 添加上游（跟踪）引用
  --submodule-prefix: string                    # 在信息性消息中打印路径前缀
  --upload-pack: string                         # 远程命令的非默认路径
  --quiet(-q)                                   # 静默内部使用的 git 命令
  --verbose(-v)                                 # 详细
  --progress                                    # 在 stderr 上报告进度
  --server-option(-o): string                   # 传递服务器处理的选项
  --show-forced-updates                         # 检查分支是否被强制更新
  --no-show-forced-updates                      # 不检查分支是否被强制更新
  -4                                            # 使用 IPv4 地址，忽略 IPv6 地址
  -6                                            # 使用 IPv6 地址，忽略 IPv4 地址
]

# 推送更改
export extern "git push" [
  remote?: string@"nu-complete git remotes",         # 远程名称
  ...refs: string@"nu-complete git local branches"   # 分支/引用规范
  --all                                              # 推送所有引用
  --atomic                                           # 请求远程端的原子事务
  --delete(-d)                                       # 删除引用
  --dry-run(-n)                                      # 干运行
  --exec: string                                     # 接收包程序
  --follow-tags                                      # 推送缺失但相关的标签
  --force-with-lease                                 # 要求引用的旧值为此值
  --force(-f)                                        # 强制更新
  --ipv4(-4)                                         # 仅使用 IPv4 地址
  --ipv6(-6)                                         # 仅使用 IPv6 地址
  --mirror                                           # 镜像所有引用
  --no-verify                                        # 绕过预推送钩子
  --porcelain                                        # 机器可读输出
  --progress                                         # 强制进度报告
  --prune                                            # 修剪本地删除的引用
  --push-option(-o): string                          # 传输选项
  --quiet(-q)                                        # 更安静
  --receive-pack: string                             # 接收包程序
  --recurse-submodules: string                       # 控制子模块的递归推送
  --repo: string                                     # 存储库
  --set-upstream(-u)                                 # 为 git pull/status 设置上游
  --signed: string                                   # GPG 签名推送
  --tags                                             # 推送标签（不能与 --all 或 --mirror 一起使用）
  --thin                                             # 使用瘦包
  --verbose(-v)                                      # 更详细
]

# 拉取更改
export extern "git pull" [
  remote?: string@"nu-complete git remotes",         # 远程名称
  ...refs: string@"nu-complete git local branches",  # 分支/引用规范
  --rebase(-r): string@"nu-complete git pull rebase",    # 获取后将当前分支变基到上游
  --quiet(-q)                                        # 在传输和合并期间抑制输出
  --verbose(-v)                                      # 更详细
  --commit                                           # 执行合并并提交结果
  --no-commit                                        # 执行合并但不提交结果
  --edit(-e)                                         # 编辑合并提交消息
  --no-edit                                          # 使用自动生成的合并提交消息
  --cleanup: string                                  # 指定如何清理合并提交消息
  --ff                                               # 如果可能，快速前进
  --no-ff                                            # 在所有情况下创建合并提交
  --gpg-sign(-S)                                     # GPG 签名合并提交
  --no-gpg-sign                                      # 不 GPG 签名合并提交
  --log: int                                         # 包含合并提交的日志消息
  --no-log                                           # 不包含合并提交的日志消息
  --signoff                                          # 添加 Signed-off-by 尾注
  --no-signoff                                       # 不添加 Signed-off-by 尾注
  --stat(-n)                                         # 在合并结束时显示 diffstat
  --no-stat                                          # 在合并结束时不显示 diffstat
  --squash                                           # 生成工作树和索引状态，仿佛发生了合并
  --no-squash                                        # 执行合并并提交结果
  --verify                                           # 运行预合并和 commit-msg 钩子
  --no-verify                                        # 不运行预合并和 commit-msg 钩子
  --strategy(-s): string                             # 使用给定的合并策略
  --strategy-option(-X): string                      # 传递合并策略特定选项
  --verify-signatures                                # 验证被合并的分支的顶端提交
  --no-verify-signatures                             # 不验证被合并的分支的顶端提交
  --summary                                          # 显示合并摘要
  --no-summary                                       # 不显示合并摘要
  --autostash                                        # 在操作前创建临时存储条目
  --no-autostash                                     # 在操作前不创建临时存储条目
  --allow-unrelated-histories                        # 允许合并没有共同祖先的历史记录
  --no-rebase                                        # 不将当前分支变基到上游分支
  --all                                              # 获取所有远程
  --append(-a)                                       # 将获取的引用附加到 FETCH_HEAD 的现有内容
  --atomic                                           # 使用原子事务更新本地引用
  --depth: int                                       # 将获取限制为指定数量的提交
  --deepen: int                                      # 按指定数量加深历史记录
  --shallow-since: string                            # 按指定日期加深或缩短历史记录
  --shallow-exclude: string                          # 排除从指定分支或标签可达的提交
  --unshallow                                        # 将浅存储库转换为完整存储库
  --update-shallow                                   # 使用新引用更新 .git/shallow
  --tags(-t)                                         # 获取远程的所有标签
  --jobs(-j): int                                    # 获取的并行子进程数
  --set-upstream                                     # 添加上游（跟踪）引用
  --upload-pack: string                              # 指定远程上传包的非默认路径
  --progress                                         # 强制进度状态，即使 stderr 不是终端
  --server-option(-o): string                        # 将给定字符串传输到服务器
]

# 在分支和提交之间切换
export extern "git switch" [
  switch?: string@"nu-complete git switch"        # 要切换到的分支名称
  --create(-c)                                    # 创建新分支
  --detach(-d): string@"nu-complete git log"      # 切换到分离状态的提交
  --force-create(-C): string                      # 强制创建新分支，如果存在则将现有分支重置为起点
  --force(-f)                                     # --discard-changes 的别名
  --guess                                         # 如果没有匹配的本地分支但有远程分支，则检出此分支
  --ignore-other-worktrees                        # 即使引用被其他工作树持有也切换
  --merge(-m)                                     # 切换分支时尝试合并更改，如果有本地更改
  --no-guess                                      # 不尝试匹配远程分支名称
  --no-progress                                   # 不报告进度
  --no-recurse-submodules                         # 不更新子模块的内容
  --no-track                                      # 不设置“上游”配置
  --orphan: string                                # 创建新的孤立分支
  --progress                                      # 报告进度状态
  --quiet(-q)                                     # 抑制反馈消息
  --recurse-submodules                            # 更新子模块的内容
  --track(-t)                                     # 设置“上游”配置
]

# 应用现有提交引入的更改
export extern "git cherry-pick" [
  commit?: string@"nu-complete git commits all" # 要挑选的提交 ID
  --edit(-e)                                    # 在提交前编辑提交消息
  --no-commit(-n)                               # 应用更改但不提交
  --signoff(-s)                                 # 在提交消息中添加 Signed-off-by 行
  --ff                                          # 如果可能，快速前进
  --continue                                    # 继续进行中的操作
  --abort                                       # 取消操作
  --skip                                        # 跳过当前提交并继续其余序列
]

# 变基当前分支
export extern "git rebase" [
  branch?: string@"nu-complete git rebase"    # 要变基到的分支名称
  upstream?: string@"nu-complete git rebase"  # 要比较的上游分支
  --continue                                  # 在编辑/解决冲突后重新启动变基过程
  --abort                                     # 中止变基并将 HEAD 重置为原始分支
  --quit                                      # 中止变基但不重置 HEAD
  --interactive(-i)                           # 交互式变基，编辑器中列出提交
  --onto?: string@"nu-complete git rebase"    # 创建新提交的起点
  --root                                      # 从根提交开始变基
]

# 从分支合并
export extern "git merge" [
  # 目前，为了简化，我们只完成分支（不提交）并支持单亲情况。
  branch?: string@"nu-complete git mergable sources"         # 源分支
  --edit(-e)                                                 # 在提交前编辑提交消息
  --no-edit                                                  # 不编辑提交消息
  --no-commit(-n)                                            # 应用更改但不提交
  --signoff                                                  # 在提交消息中添加 Signed-off-by 行
  --ff                                                       # 如果可能，快速前进
  --continue                                                 # 解决冲突后继续
  --abort                                                    # 中止解决冲突并返回原始状态
  --quit                                                     # 忘记当前进行中的合并
  --strategy(-s): string@"nu-complete git merge strategies"  # 合并策略
  -X: string@"nu-complete git merge strategy options"        # 合并策略选项
  --verbose(-v)
  --help
]

# 列出或更改分支
export extern "git branch" [
  branch?: string@"nu-complete git local branches"               # 要操作的分支名称
  --abbrev                                                       # 使用短提交哈希前缀
  --edit-description                                             # 打开编辑器编辑分支描述
  --merged                                                       # 列出可达分支
  --no-merged                                                    # 列出不可达分支
  --set-upstream-to: string@"nu-complete git available upstream" # 设置分支的上游
  --unset-upstream                                               # 删除分支的上游
  --all                                                          # 列出远程和本地分支
  --copy                                                         # 复制分支及其配置和 reflog
  --format                                                       # 指定列出分支的格式
  --move                                                         # 重命名分支
  --points-at                                                    # 列出指向对象的分支
  --show-current                                                 # 打印当前分支的名称
  --verbose                                                      # 显示每个分支的提交和上游
  --color                                                        # 在输出中使用颜色
  --quiet                                                        # 抑制消息，除非错误
  --delete(-d)                                                   # 删除分支
  --list                                                         # 列出分支
  --contains: string@"nu-complete git commits all"               # 仅显示包含指定提交的分支
  --no-contains                                                  # 仅显示不包含指定提交的分支
  --track(-t)                                                    # 创建分支时设置上游
]

# 列出配置文件中设置的所有变量及其值。
export extern "git config list" [
]

# 输出指定键的值。
export extern "git config get" [
]

# 为一个或多个配置选项设置值。
export extern "git config set" [
]

# 取消设置一个或多个配置选项的值。
export extern "git config unset" [
]

# 将给定部分重命名为新名称。
export extern "git config rename-section" [
]

# 从配置文件中删除给定部分。
export extern "git config remove-section" [
]

# 打开编辑器来修改指定的配置文件
export extern "git config edit" [
]

# 列出或更改跟踪的存储库
export extern "git remote" [
  --verbose(-v)                            # 显示远程的 URL
]

# 添加新的跟踪存储库
export extern "git remote add" [
]

# 重命名跟踪存储库
export extern "git remote rename" [
  remote: string@"nu-complete git remotes"             # 要重命名的远程
  new_name: string                                     # 远程的新名称
]

# 删除跟踪存储库
export extern "git remote remove" [
  remote: string@"nu-complete git remotes"             # 要删除的远程
]

# 获取跟踪存储库的 URL
export extern "git remote get-url" [
  remote: string@"nu-complete git remotes"             # 要获取 URL 的远程
]

# 设置跟踪存储库的 URL
export extern "git remote set-url" [
  remote: string@"nu-complete git remotes"             # 要设置 URL 的远程
  url: string                                          # 远程的新 URL
]

# 显示提交、工作树等之间的更改
export extern "git diff" [
  rev1_or_file?: string@"nu-complete git files-or-refs"
  rev2?: string@"nu-complete git refs"
  --cached                                             # 显示已暂存的更改
  --name-only                                          # 仅显示更改的文件名
  --name-status                                        # 显示更改的文件和更改类型
  --no-color                                           # 禁用彩色输出
]

# 提交更改
export extern "git commit" [
  --all(-a)                                           # 自动暂存所有修改和删除的文件
  --amend                                             # 修改上一个提交而不是添加新提交
  --message(-m): string                               # 指定提交消息而不是打开编辑器
  --reuse-message(-C): string                         # 重用之前提交的消息
  --reedit-message(-c): string                        # 重用并编辑提交的消息
  --fixup: string                                     # 创建修正/修改提交
  --squash: string                                    # 为自动压缩变基压缩提交
  --reset-author                                      # 重置作者信息
  --short                                             # 干运行的短格式输出
  --branch                                            # 在短格式中显示分支信息
  --porcelain                                         # 干运行的瓷器就绪格式
  --long                                              # 干运行的长格式输出
  --null(-z)                                          # 在输出中使用 NUL 而不是 LF
  --file(-F): string                                  # 从文件中读取提交消息
  --author: string                                    # 覆盖提交作者
  --date: string                                      # 覆盖作者日期
  --template(-t): string                              # 使用提交消息模板文件
  --signoff(-s)                                       # 添加 Signed-off-by 尾注
  --no-signoff                                        # 不添加 Signed-off-by 尾注
  --trailer: string                                   # 在提交消息中添加尾注
  --no-verify(-n)                                     # 绕过预提交和 commit-msg 钩子
  --verify                                            # 不绕过预提交和 commit-msg 钩子
  --allow-empty                                       # 允许没有更改的提交
  --allow-empty-message                               # 允许空消息提交
  --cleanup: string                                   # 清理提交消息
  --edit(-e)                                          # 编辑提交消息
  --no-edit                                           # 不编辑提交消息
  --include(-i)                                       # 在提交中包含给定路径
  --only(-o)                                          # 仅提交指定路径
  --pathspec-from-file: string                        # 从文件中读取路径规范
  --pathspec-file-nul                                 # 使用 NUL 字符分隔路径规范文件
  --untracked-files(-u): string                       # 显示未跟踪的文件
  --verbose(-v)                                       # 在提交消息模板中显示差异
  --quiet(-q)                                         # 抑制提交摘要
  --dry-run                                           # 显示要提交的路径而不提交
  --status                                            # 在提交消息中包含 git-status 输出
  --no-status                                         # 在提交消息中不包含 git-status 输出
  --gpg-sign(-S)                                      # GPG 签名提交
  --no-gpg-sign                                       # 不 GPG 签名提交
  ...pathspec: string                                 # 提交匹配路径规范的文件
]

# 列出提交
export extern "git log" [
  # 理想情况下，我们会在此处允许修订完成，但这会使文件名的完成无法工作。
  -U                                                  # 显示差异
  --follow                                            # 显示重命名后的历史记录（仅限单个文件）
  --grep: string                                      # 显示匹配提供的正则表达式的日志条目
]

# 显示或更改 reflog
export extern "git reflog" [
]

# 暂存文件
export extern "git add" [
  ...file: string@"nu-complete git add"               # 要添加的文件
  --all(-A)                                           # 添加所有文件
  --dry-run(-n)                                       # 实际上不添加文件，只显示它们是否存在和/或将被忽略
  --edit(-e)                                          # 在编辑器中打开与索引的差异并让用户编辑
  --force(-f)                                         # 允许添加被忽略的文件
  --interactive(-i)                                   # 交互式添加工作树中修改的内容到索引
  --patch(-p)                                         # 交互选择块以暂存
  --verbose(-v)                                       # 详细
]

# 从工作树和索引中删除文件
export extern "git rm" [
  -r                                                   # 递归
  --force(-f)                                          # 覆盖最新检查
  --dry-run(-n)                                        # 实际上不删除任何文件
  --cached                                             # 仅从索引中取消暂存和删除路径
]

# 显示工作树状态
export extern "git status" [
  --verbose(-v)                                       # 详细
  --short(-s)                                         # 简洁显示状态
  --branch(-b)                                        # 显示分支信息
  --show-stash                                        # 显示存储信息
]

# 存储更改以备后用
export extern "git stash push" [
  --patch(-p)                                         # 交互选择块以存储
]

# 弹出之前存储的更改
export extern "git stash pop" [
  stash?: string@"nu-complete git stash-list"          # 要弹出的存储
  --index(-i)                                          # 尝试恢复工作树的更改以及索引的更改
]

# 列出存储的更改
export extern "git stash list" [
]

# 显示存储的更改
export extern "git stash show" [
  stash?: string@"nu-complete git stash-list"
  -U                                                  # 显示差异
]

# 删除存储的更改
export extern "git stash drop" [
  stash?: string@"nu-complete git stash-list"
]

# 创建新的 git 存储库
export extern "git init" [
  --initial-branch(-b): string                         # 初始分支名称
]

# 列出或操作标签
export extern "git tag" [
  --delete(-d): string@"nu-complete git tags"         # 删除标签
]

# 修剪所有不可达对象
export extern "git prune" [
  --dry-run(-n)                                       # 干运行
  --expire: string                                    # 过期对象
  --progress                                          # 显示进度
  --verbose(-v)                                       # 报告所有删除的对象
]

# 启动二分搜索以查找引入错误的提交
export extern "git bisect start" [
  bad?: string                 # 有错误的提交
  good?: string                # 没有错误的提交
]

# 将当前（或指定的）修订标记为错误
export extern "git bisect bad" [
]

# 将当前（或指定的）修订标记为正确
export extern "git bisect good" [
]

# 跳过当前（或指定的）修订
export extern "git bisect skip" [
]

# 结束二分搜索
export extern "git bisect reset" [
]

# 显示 git 子命令的帮助
export extern "git help" [
  command?: string@"nu-complete git subcommands"       # 要显示帮助的子命令
]

# git 工作树
export extern "git worktree" [
  --help(-h)            # 显示此命令的帮助消息
  ...args
]

# 创建新的工作树
export extern "git worktree add" [
  path: path            # 克隆分支的目录
  branch: string@"nu-complete git available upstream" # 要克隆的分支
  --help(-h)            # 显示此命令的帮助消息
  --force(-f)           # 即使已在其他工作树中检出，也检出 <branch>
  -b                    # 创建新分支
  -B                    # 创建或重置分支
  --detach(-d)          # 在指定提交处分离 HEAD
  --checkout            # 填充新的工作树
  --lock                # 保持新的工作树锁定
  --reason              # 锁定原因
  --quiet(-q)           # 抑制进度报告
  --track               # 设置跟踪模式（参见 git-branch(1)）
  --guess-remote        # 尝试将新分支名称与远程跟踪分支匹配
  ...args
]

# 列出每个工作树的详细信息
export extern "git worktree list" [
  --help(-h)            # 显示此命令的帮助消息
  --porcelain           # 机器可读输出
  --verbose(-v)         # 显示扩展注释和原因（如果有）
  --expire              # 为超过 <time> 的工作树添加 'prunable' 注释
  -z                    # 使用 NUL 字符终止记录
  ...args
]

def "nu-complete worktree list" [] {
  ^git worktree list | to text | parse --regex '(?P<value>\S+)\s+(?P<commit>\w+)\s+(?P<description>\S.*)'
}

# 防止工作树被修剪
export extern "git worktree lock" [
  worktree: string@"nu-complete worktree list"
  --reason: string      # 锁定原因
  --help(-h)            # 显示此命令的帮助消息
  --reason              # 锁定原因
  ...args
]

# 将工作树移动到新位置
export extern "git worktree move" [
  --help(-h)            # 显示此命令的帮助消息
  --force(-f)           # 即使工作树脏或锁定也强制移动
  ...args
]

# 修剪工作树信息
export extern "git worktree prune" [
  --help(-h)            # 显示此命令的帮助消息
  --dry-run(-n)         # 不删除，只显示
  --verbose(-v)         # 报告修剪的工作树
  --expire              # 过期超过 <time> 的工作树
  ...args
]

# 删除工作树
export extern "git worktree remove" [
  worktree: string@"nu-complete worktree list"
  --help(-h)            # 显示此命令的帮助消息
  --force(-f)           # 即使工作树脏或锁定也强制删除
]

# 允许工作树被修剪、移动或删除
export extern "git worktree unlock" [
  worktree: string@"nu-complete worktree list"
  ...args
]

# 克隆存储库
export extern "git clone" [
  --help(-h)                    # 显示此命令的帮助消息
  --local(-l)                   # 从本地机器克隆
  --no-local                    # 即使从本地路径克隆，也使用 git 传输机制
  --no-hardlinks                # 从本地机器克隆时强制 git 复制文件
  --shared(-s)                  # 设置 .git/objects/info/alternates 以与源本地存储库共享对象
  --reference: string           # 设置 .git/objects/info/alternates 以与 =<reference> 本地存储库共享对象
  --reference-if-able: string   # 与 --reference 相同，但跳过空文件夹
  --dissociate                  # 从引用的存储库（--reference）借用对象
  --quiet(-q)                   # 抑制进度报告
  --verbose(-v)                 # 详细
  --progress                    # 报告进度，除非 --quiet
  --server-option: string       # 将 =<option> 传输到服务器
  --no-checkout(-n)             # 不检出 HEAD
  --reject-shallow              # 拒绝浅存储库作为源
  --no-reject-shallow           # 不拒绝浅存储库作为源
  --bare                        # 创建裸 git 存储库
  --sparse                      # 初始化稀疏检出文件
  --filter: string              # 使用给定的 =<filter-spec> 进行部分克隆
  --mirror                      # 镜像源存储库
  --origin(-o): string          # 使用 <name> 作为远程源的名称
  --branch(-b): string          # 将 HEAD 指向 <name> 分支
  --upload-pack(-u): string     # 使用 ssh 时在另一端的路径
  --template: string            # 使用 <template-dir> 作为模板目录
  --config(-c): string          # 设置 <key>=<value> 配置变量
  --depth: int                  # 浅克隆 <depth> 次提交
  --shallow-since: string       # 浅克隆比 =<date> 更新的提交
  --shallow-exclude: string     # 不克隆从 <revision>（分支或标签）可达的提交
  --single-branch               # 从单个分支克隆提交历史
  --no-single-Branch            # 不仅克隆一个分支
  --no-tags                     # 不克隆任何标签
  --recurse-submodules          # 克隆子模块。也接受路径
  --shallow-submodules          # 使用深度 1 浅克隆子模块
  --no-shallow-submodules       # 不浅克隆子模块
  --remote-submodules           # 使用其远程跟踪分支更新子模块
  --no-remote-submodules        # 不跟踪子模块远程
  --separate-git-dir: string    # 将克隆放在 =<git dir> 并在此处链接
  --jobs(-j): int               # 并行子模块获取数
  ...args
]

# 恢复工作树或索引中的文件到以前的版本
export extern "git restore" [
  --help(-h)                                    # 显示此命令的帮助消息
  --source(-s)                                  # 使用给定树的内容恢复工作树文件
  --patch(-p)                                   # 交互选择块以恢复
  --worktree(-W)                                # 恢复工作树（如果未使用 --worktree 或 --staged，则为默认）
  --staged(-S)                                  # 恢复索引
  --quiet(-q)                                   # 安静，抑制反馈消息
  --progress                                    # 强制进度报告
  --no-progress                                 # 抑制进度报告
  --ours                                        # 使用我们的版本从索引中恢复未合并的文件
  --theirs                                      # 使用他们的版本从索引中恢复未合并的文件
  --merge(-m)                                   # 从索引中恢复并在未合并的文件中重新创建冲突的合并
  --conflict: string                            # 类似 --merge，但更改冲突呈现样式
  --ignore-unmerged                             # 从索引中恢复并忽略未合并的条目（未合并的文件保持不变）
  --ignore-skip-worktree-bits                   # 忽略稀疏检出模式，无条件恢复 <pathspec> 中的任何文件
  --recurse-submodules                          # 恢复工作树中子模块的内容
  --no-recurse-submodules                       # 不恢复工作树中子模块的内容（默认）
  --overlay                                     # 从树中恢复时不删除不存在的文件
  --no-overlay                                  # 从树中恢复时删除不存在的文件（默认）
  --pathspec-from-file: string                  # 从文件中读取路径规范
  --pathspec-file-nul                           # 从文件中读取路径规范时使用 NUL 字符分隔路径规范元素
  ...pathspecs: string@"nu-complete git files"  # 要恢复的目标路径规范
]

# 打印匹配模式的行
export extern "git grep" [
  --help(-h)                            # 显示此命令的帮助消息
  --cached                              # 搜索索引文件中注册的 blob 而不是工作树
  --untracked                           # 在搜索中包含未跟踪的文件
  --no-index                            # 类似于 `grep -r`，但有额外的好处，例如使用路径规范模式限制路径；不能与 --cached 或 --untracked 一起使用
  --no-exclude-standard                 # 在搜索中包含被忽略的文件（仅在 --untracked 有用）
  --exclude-standard                    # 在搜索中不包含被忽略的文件（仅在 --no-index 有用）
  --recurse-submodules                  # 递归搜索每个活动且已检出的子模块
  --text(-a)                            # 将二进制文件视为文本处理
  --textconv                            # 尊重 textconv 过滤器设置
  --no-textconv                         # 不尊重 textconv 过滤器设置（默认）
  --ignore-case(-i)                     # 忽略模式和文件之间的大小写差异
  -I                                    # 不在二进制文件中匹配模式
  --max-depth: int                      # 限制每个路径规范的目录深度。值为 -1 表示无限制。
  --recursive(-r)                       # 等同于 --max-depth=-1
  --no-recursive                        # 等同于 --max-depth=0
  --word-regexp(-w)                     # 仅在单词边界匹配模式
  --invert-match(-v)                    # 选择不匹配的行
  -H                                    # 在匹配行的输出中抑制文件名
  --full-name                           # 强制相对路径从顶级目录到文件名
  --extended-regexp(-E)                 # 使用 POSIX 扩展正则表达式匹配模式
  --basic-regexp(-G)                    # 使用 POSIX 基本正则表达式匹配模式（默认）
  --perl-regexp(-P)                     # 使用 Perl 兼容正则表达式匹配模式
  --line-number(-n)                     # 在匹配行前添加行号
  --column                              # 在匹配行的开头添加第一个匹配的 1 索引字节偏移量
  --files-with-matches(-l)              # 打印包含匹配的文件名
  --name-only                           # 等同于 --files-with-matches
  --files-without-match(-L)             # 打印不包含匹配的文件名
  --null(-z)                            # 在输出中使用 \0 作为路径名的分隔符，并逐字打印它们
  --only-matching(-o)                   # 仅打印匹配行的匹配（非空）部分，每个部分在单独的输出行上
  --count(-c)                           # 不显示每个匹配行，而是显示匹配行的数量
  --no-color                            # 等同于 --color=never
  --break                               # 在不同文件的匹配之间打印空行。
  --heading                             # 在文件名上方显示匹配文件的匹配，而不是在每个显示行的开头。
  --show-function(-p)                   # 显示包含匹配的函数名称的前一行，除非匹配行本身是函数名称。
  --context(-C): int                    # 显示 <num> 个前导和后续行，并在连续的匹配组之间放置包含 -- 的行。
  --after-context(-A): int              # 显示 <num> 个后续行，并在连续的匹配组之间放置包含 -- 的行。
  --before-context(-B): int             # 显示 <num> 个前导行，并在连续的匹配组之间放置包含 -- 的行。
  --function-context(-W)                # 显示从包含函数名称的前一行到下一个函数名称之前的周围文本
  --max-count(-m): int                  # 限制每个文件的匹配数量。使用 -v 或 --invert-match 选项时，搜索在指定数量的不匹配后停止。
  --threads: int                        # 使用的 grep 工作线程数。有关 grep 线程的更多信息，请使用 --help。
  -f: string                            # 从 <file> 中读取模式，每行一个。
  -e: string                            # 下一个参数是模式。多个模式由 --or 组合。
  --and                                 # 搜索匹配多个模式的行。
  --or                                  # 搜索匹配至少一个模式的行。模式之间没有 --and 或 --not 时隐含 --or。
  --not                                 # 搜索不匹配模式的行。
  --all-match                           # 给出多个模式表达式与 --or 组合时，此标志用于限制匹配到包含所有模式的文件。
  --quiet(-q)                           # 不输出匹配行；相反，当有匹配时以状态 0 退出，没有匹配时以非零状态退出。
  ...pathspecs: string                  # 限制搜索范围的目标路径规范。
]

export extern "git" [
  command?: string@"nu-complete git subcommands"   # 子命令
  --version(-v)                                    # 打印 git 程序来自的 Git 套件版本
  --help(-h)                                       # 打印概要和最常用命令的列表
  --html-path                                      # 打印 Git 的 HTML 文档安装路径（不带尾随斜杠）并退出
  --man-path                                       # 打印此版本 Git 的 manpath（参见 man(1)）并退出
  --info-path                                      # 打印此版本 Git 的 Info 文件安装路径并退出
  --paginate(-p)                                   # 如果标准输出是终端，则将所有输出传输到 less（或如果设置，则为 $env.PAGER）
  --no-pager(-P)                                   # 不将 Git 输出传输到分页器
  --no-replace-objects                             # 不使用替换引用替换 Git 对象
  --bare                                           # 将存储库视为裸存储库
]
