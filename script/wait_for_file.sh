wait_for_file() {
  local file="$1"; shift
  local wait_seconds="${1:-10}"; shift # 10 seconds as default timeout

  until [ $((wait_seconds--)) -eq 0 -o -f "$file" ] ; do sleep 1; done

  [ "$wait_seconds" -ne -1 ]
}
