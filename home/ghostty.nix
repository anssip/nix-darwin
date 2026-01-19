{ ... }:
{
  xdg.configFile."ghostty/config".text = ''
    # ghostty +show-config --default --docs | nvim

    # font-family = JuliaMono
    font-family = UbuntuMono Nerd Font Mono
    font-size = 18

    # ghostty +list-theme
    theme = Kolorit
    # theme = catppuccin-frappe
    # theme = iceberg-dark
    # theme = Dracula

    mouse-hide-while-typing = true

    # macos-titlebar-style = hidden
    # macos-titlebar-proxy-icon = hidden
    # macos-option-as-alt = true

    copy-on-select = clipboard
    shell-integration-features = cursor,sudo,no-title

    # enable transparency
    background-opacity = 0.80
    background-blur = true

    keybind = shift+enter=text:\n
    keybind = alt+2=text:@

    # Split terminal borders
    split-divider-color = #6272a4
    unfocused-split-opacity = 0.85
  '';
}
