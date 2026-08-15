{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "章家铭";
        email = "zhang_jia_ming@outlook.com";
        signingKey = "143CA697734657CE";
      };
      commit.gpgSign = true;
      init.defaultBranch = "main";
    };
  };
}
