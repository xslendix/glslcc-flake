{
	description = "GLSL Cross Compiler (glslcc)";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
	};

	outputs = { self, nixpkgs, ... }:
		let
			system = "x86_64-linux";
			version = "master";
			pkgs = import nixpkgs { inherit system; };

			runtimeLibs = with pkgs; [
				zlib gcc cmake pkg-config
				spirv-tools glslang
			];

			mkGlslcc = pkgs.stdenv.mkDerivation rec {
				pname = "glslcc";
				inherit version;

				src = pkgs.fetchFromGitHub {
					owner = "septag";
					repo = "glslcc";
					rev = version;
					sha256 = "0p373wzz6xa6lmlsxaz08gniry9ckv3bynlgw26vs7knmr85n9vn";
				};

				nativeBuildInputs = [ pkgs.cmake pkgs.gcc pkgs.pkg-config pkgs.ninja ];
				buildInputs = runtimeLibs;

				buildPhase = ''
					mkdir -p build
					cd build
					cmake .. -DCMAKE_BUILD_TYPE=Release
					cd .. 
					make -j$(nproc)
				'';

				installPhase = ''
					mkdir -p $out/bin
					cp src/glslcc $out/bin/glslcc
				'';

				meta = with pkgs.lib; {
					description = "GLSL cross-compiler tool (GLSL->HLSL, MSL, GLES2, GLES3, GLSLv3), using SPIRV-cross and glslang.";
					license = licenses.mit;
					platforms = platforms.linux;
				};
			};
		in {
			packages.${system} = {
				default = mkGlslcc;
			};
			
			devShell.${system} = pkgs.mkShell {
				buildInputs = [ mkGlslcc ];
			};
		};
}
