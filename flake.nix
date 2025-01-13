{
  description = "Python Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: 
    
    let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowBroken = true;
        };
      };

      pythonEnv = pkgs.python3.withPackages (pythonPackages: with pythonPackages; [
        pip
        virtualenv
        jupyterlab
        torch
        matplotlib
        tiktoken
        tqdm
        numpy
        pandas
        psutil
        setuptools
      ]);

    in {
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.git
          pythonEnv
        ];

        shellHook = ''
          # Create a virtual environment if it doesn't exist
          if [ ! -d ".venv" ]; then
            python -m venv .venv
          fi

          # Activate the virtual environment
          source .venv/bin/activate
          
          # Upgrade pip to the latest version
          pip install --upgrade pip
          
          # Install TensorFlow 2.16.2 if not already installed
          # TensorFlow 2.16.2 is the last version working with x86_64-darwin
          if ! python -c "import tensorflow" &> /dev/null; then
            pip install tensorflow==2.16.2
          fi
          
          echo "Welcome to the Python Dev Environment with TensorFlow!"
          
          # jupyter lab --notebook-dir=~/
        '';
      };
    });
}
