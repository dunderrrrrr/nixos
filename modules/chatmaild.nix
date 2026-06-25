{
  lib,
  python3,
  fetchFromGitHub,
}:
python3.pkgs.buildPythonPackage {
  pname = "chatmaild";
  version = "0.3-unstable-2025-06-25";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chatmail";
    repo = "relay";
    rev = "cb1e4ff5bbfc179139749df2e218fc61e631fd63";
    hash = "sha256-NyJ/rL1I3roqvcbzIBXiNiGb6kNV3Y3+IuGATBdqX7U=";
  };

  sourceRoot = "source/chatmaild";

  build-system = [python3.pkgs.setuptools];

  dependencies = with python3.pkgs; [
    iniconfig
    filelock
    requests
    passlib
  ];

  postPatch = ''
        substituteInPlace src/chatmaild/doveauth.py \
          --replace-fail \
            'try:
        import crypt_r
    except ImportError:
        import crypt as crypt_r' \
            'from passlib.hash import sha512_crypt as _sha512_crypt
    class crypt_r:
        METHOD_SHA512 = None
        @staticmethod
        def crypt(password, method=None):
            return _sha512_crypt.hash(password)
    '
  '';

  pythonRemoveDeps = ["crypt-r"];

  doCheck = false;
}
