# The default applications corresponding to mime types
{ ... }:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
      "x-scheme-handler/mailto" = "thunderbird.desktop";
      "x-scheme-handler/file" = "org.kde.dolphin.desktop";
      "text/plain" = "code.desktop";
      "application/pdf" = "okular.desktop";
      "default-web-browser " = "firefox.desktop";
    };
  };
}
