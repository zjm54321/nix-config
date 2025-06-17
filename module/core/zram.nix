{
  # 启用 zram 内核模块提供的内存压缩设备和交换空间。
  # 通过启用此功能，我们可以在内存中存储更多数据，而不是直接回退到基于磁盘的交换设备，
  # 从而在拥有大量内存的情况下提高 I/O 性能。
  #
  #   https://www.kernel.org/doc/Documentation/blockdev/zram.txt
  zramSwap = {
    enable = true;
    # 压缩算法选项："lzo"、"lz4"、"zstd"
    algorithm = "zstd";
    # zram 交换设备的优先级。
    # 它应该高于基于磁盘的交换设备的优先级
    # （这样系统会先填满 zram 交换设备，然后才会使用磁盘交换）。
    priority = 5;
    # zram 交换设备可以存储的最大内存总量（占总内存的百分比）。
    # 默认为总 RAM 的 1/2。运行 zramctl 可以检查内存压缩效果如何。
    # 这不定义 zram 交换设备将使用多少内存。
    memoryPercent = 50;
  };
}
