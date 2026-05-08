{ ... }:
{
  # System Module ollama: run Ollama with ROCm GPU acceleration for local LLM inference (EliasPC only)
  flake.modules.nixos.ollama = { pkgs, ... }: {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      rocmOverrideGfx = "10.3.0";
      loadModels = [ "qwen3.5:4b" "qwen3.5:9b" ]; # ~2.6 GB + ~5.8 GB VRAM
      environmentVariables.OLLAMA_KEEP_ALIVE = "5m";
    };
  };
}
