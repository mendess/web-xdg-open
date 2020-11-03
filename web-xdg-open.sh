#!/bin/bash

target="$1"

fallback() {
    /usr/bin/xdg-open "$1"
    exit
}

case "$target" in
    http*)
        clean_link=${target,,}
        clean_link=${clean_link%\?*}
        status_code=$(curl -s -o /dev/null -w "%{http_code}" "$target")
        [[ $status_code != 200 ]] &&
            [[ $status_code != 3?? ]] &&
            notify-send 'Test curl failed' "Status code: $status_code" &&
            fallback "$target"
        case "$clean_link" in
            *github*blob*)
                git_link="${target//github/raw.githubusercontent}"
                git_link="${git_link//blob\//}"
                file=/tmp/$(basename "$git_link")
                notify-send 'opening from github' "$git_link" -u low
                curl --silent "$git_link" >"$file"
                app=$(xdg-mime query default "$(xdg-mime query filetype "$file")")
                # if the app is not vim, then the fallback at the end of the case will be used
                [[ "$app" = *vim.desktop ]] && $TERMINAL -e bash -c "nvim '$file'"
                rm "$file"
                ;;
            *.txt | *.sh | *.c | *.cpp | *.h | *.hpp | *.rs | *.spell | *.tool | *.hs | *.conf | *.tex | *.log | *.lhs | *.java | *.py | *.awk | *.pl | *.cs | *.css | *.js | *.scss | *.lua | *.bash | *makefile)
                t=$(mktemp)
                curl --silent "$target" >"$t"
                $TERMINAL -e bash -c "nvim '$t'"
                rm "$t"
                ;;
            *.png | *.jpg | *.jpeg | *.bmp | *.tiff | *.svg | *.ico | *.img)
                t=$(mktemp)
                curl --silent "$target" >"$t"
                size="$(file "$t" | sed -E 's/.* ([0-9]+)\s*x\s*([0-9]+).*/\1x\2/')"
                set -x
                w=${size%x*}
                h=${size#*x}
                if [[ $h -gt 1000 ]]; then
                    w=$(((w * 1000) / h))
                    h=1000
                fi
                if [[ $w -gt 1800 ]]; then
                    h=$(((h * 1800) / w))
                    w=1800
                fi
                sxiv -b -g "${w}x${h}" "$t"
                set +x
                rm "$t"
                ;;
            *.gif)
                notify-send 'Playing in mpv' "$target" -u low
                mpv --loop-file "$target"
                ;;
            *.pdf | *.djvu)
                curl --silent "$target" | zathura -
                ;;
            *youtube* | *youtu.be* | *clips.twitch.tv* | https://v.redd.it* | https://t.co* | *.avi | *.webm | *.mp4 | *.mp3 | *.wav | *.flac | *.midi | *.dvdrip | *.cam | *.mkv | *.mov | *.mpeg | *.flv | *.mpg | *.mp2 | *.mpv | *.m4p | *.m4v | *.wmv | *.qt | *.swf | *.avchd | *.m4a | *.ogg | *.wma | *.amv | *.mpa | *.ra | *.rax | *.raw | *.smf | *.snd | *.sng | *.swa | *.hma | *.aac | *.ac3 | *.eac3 | *.Vorbis | *.pcm)
                notify-send 'Playing in mpv' "$target" -u low
                mpv "$target" || {
                    notify-send 'Retrying in mpv' "$target" -u low
                    mpv "$target"
                }
                ;;
            *.pub)
                notify-send 'Key coppied to clipboard' -u low
                curl -s "$target" | xclip
                ;;
            *)
                fallback "$target"
                ;;
        esac || fallback "$target"
        ;;
    *)
        fallback "$target"
        ;;
esac
