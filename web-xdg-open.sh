#!/bin/bash
set -o pipefail

[[ ! "$1" ]] &&
    echo "Usage: $0 link" &&
    exit 1

readonly CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/wxorc"
readonly APP_NAME="$(basename "$0")"

## ============== PUBLIC OVERRIDABLE METHODS ================
notify() {
    notify-send -a "$APP_NAME" "$@"
    true
}

image() {
    dl "$1" >"$TEMPFILE" && xdg-open "$TEMPFILE"
}

video() {
    if command -V mpv &>/dev/null; then
        notify 'Playing in mpv' "$1" -u low
        mpv "$1" || {
            notify 'Retrying in mpv' "$1" -u low
            mpv "$1"
        }
    else
        notify 'Downloading' "$1"
        if ! error=$(youtube-dl --no-color "$1" --output "$TEMPFILE"); then
            notify 'Download failed' "$error" -u critical
            return 1
        else
            xdg-open "$TEMPFILE"
        fi
    fi
}

text() {
    dl "$1" >"$TEMPFILE" && xdg-open "$TEMPFILE"
}

git() {
    dl "$1" >"$TEMPFILE" && xdg-open "$TEMPFILE"
}

gif() {
    if command -V mpv &>/dev/null; then
        mpv --loop-file "$1"
    else
        dl "$1" && xdg-open "$TEMPFILE"
    fi
}

pdf() {
    dl "$1" >"$TEMPFILE" && xdg-open "$TEMPFILE"
}

clipboard() {
    if command -V xclip &>/dev/null; then
        dl "$1" | xclip && notify 'Key coppied to clipboard' -u low
    else
        notify 'xclip not installed' \
            'Install it or override the behaviour of clipboard' \
            -u low
    fi
}

archive() {
    false
    #dl "$1" >"$TEMPFILE" && xdg-open "$TEMPFILE"
}

fallback() {
    notify 'Using fallback' -u low
    if [[ "$BROWSER" ]]; then
        "$BROWSER" "$1" &
        disown
    else
        notify 'Browser not set' \
            "Please set the \$BROWSER enviroment variable" \
            -u critical
        false
    fi
    exit
}

dl() {
    __bash_not_smart_enough() {
        local error
        if ! error=$(curl -# --fail "$1" 3>&2 2>&1 1>&3); then
            notify 'Download failed' \
                "$(tail -1 <<<"$error" | sed -E 's/curl:\s*\([0-9]*\)//g')" \
                -u critical
            return 1
        fi
    }
    __bash_not_smart_enough "$@" 2>&1
}

__temp_file() {
    TEMPFILE=$(mktemp) || return 1
    if [[ "$1" ]]; then
        name="$(basename "$1")"
        [[ "$name" = */* ]] && return 0
        mv "$TEMPFILE" "$TEMPFILE-$name" || return 1
        TEMPFILE="$TEMPFILE-$name"
    fi
}

## ============== PRIVATE METHODS ================

__cleanup() {
    sleep 30
    [[ "$TEMPFILE" ]] && rm -f "$TEMPFILE"
    :
}

trap __cleanup EXIT

readonly target="$1"

__try() {
    clean_link=${target,,}
    clean_link=${clean_link%\?*}
    case "$clean_link" in
        *github*blob*)
            raw_link="${target//github/raw.githubusercontent}"
            raw_link="${raw_link//blob\//}"
            git "$raw_link"
            ;;
        *.txt | *.sh | *.c | *.cpp | *.h | *.hpp | *.rs | *.spell | *.tool | *.hs | *.conf | *.tex | *.log | *.lhs | *.java | *.py | *.awk | *.pl | *.cs | *.css | *.js | *.scss | *.lua | *.bash | *makefile)
            text "$target"
            ;;
        *.png | *.jpg | *.jpeg | *.bmp | *.tiff | *.svg | *.ico | *.img | *.webp)
            image "$target"
            ;;
        *.gif)
            gif "$target"
            ;;
        *.pdf | *.djvu)
            pdf "$target"
            ;;
        *.tar | *.bz2 | *.rar | *.Z | *.7z | *.gz | *.xz | *.zip)
            archive "$target"
            ;;
        *youtube.com* | *youtu.be* | *clips.twitch.tv* | https://v.redd.it* | https://t.co* | *streamable.com* | *.avi | *.webm | *.mp4 | *.mp3 | *.wav | *.flac | *.midi | *.dvdrip | *.cam | *.mkv | *.mov | *.mpeg | *.flv | *.mpg | *.mp2 | *.mpv | *.m4p | *.m4v | *.wmv | *.qt | *.swf | *.avchd | *.m4a | *.ogg | *.wma | *.amv | *.mpa | *.ra | *.rax | *.raw | *.smf | *.snd | *.sng | *.swa | *.hma | *.aac | *.ac3 | *.eac3 | *.Vorbis | *.pcm)
            video "$target"
            ;;
        *.pub)
            clipboard "$target"
            ;;
        *) false ;;
    esac
}

#shellcheck disable=1090
. "$CONFIG"

__temp_file "$1" || fallback "$target"

__try || fallback "$target"
