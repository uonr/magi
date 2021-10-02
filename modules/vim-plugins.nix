{ pkgs, ... }:
with pkgs.vimPlugins;
let 
  vim-chinese-document = pkgs.vimUtils.buildVimPlugin {
    name = "vimcdoc";
    pname = "vimcdoc";
    src = pkgs.fetchFromGitHub {
      owner = "yianwillis";
      repo = "vimcdoc";
      rev = "5ac9747e58bd25672f094c4f6846291cb785629c";
      sha256 = "eF9KAQI5RE6r9i7TfTC4NU1+y2vQwkRe0RxjenNsIBU=";
    };
  };
  neovim-beacon = pkgs.vimUtils.buildVimPlugin {
    name = "beacon-nvim";
    pname = "beacon-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "DanilaMihailov";
      repo = "beacon.nvim";
      rev = "065d7fa03e43ea9c86744ce5a145115b384c38ce";
      sha256 = "ajYJbUW9Z4cfspzmt8NXnCoEqglO7R+nnwX5W3D6zLs=";
    };
  };
in [
  nvim-autopairs
  editorconfig-vim
  vim-airline
  vim-airline-themes
  vim-surround
  vim-chinese-document
  vim-easymotion
  vim-fish
  gruvbox
  vim-repeat
  vim-sleuth
  vim-nix
  indent-blankline-nvim-lua
  vim-commentary
  neovim-beacon
]
