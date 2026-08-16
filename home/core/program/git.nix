{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "zjm54321";
        email = "zhang_jia_ming@outlook.com";
        signingKey = "143CA697734657CE";
      };
      commit.gpgSign = true;
      init.defaultBranch = "main";
    };
  };
}
