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
      "application/pdf" = "firefox.desktop";
      "default-web-browser " = "firefox.desktop";
      "text/calendar" = "thunderbird.desktop";
      "message/rfc822" = "thunderbird.desktop";
      "application/x-extension-ics" = "thunderbird.desktop";
      "terminal" = "kitty.desktop";
    };
    associations.added = {
      "inode/directory" = "code.desktop";
      "x-scheme-handler/mailto" = "thunderbird.desktop";
      "x-scheme-handler/mid" = "thunderbird.desktop";
      "x-scheme-handler/webcal" = "thunderbird.desktop";
      "x-scheme-handler/webcals" = "thunderbird.desktop";
    };
  };
}
