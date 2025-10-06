#!/usr/bin/env bash

set -e

dpkg --add-architecture amd64 \
    && apt update \
    && apt install -y libc6:amd64 libxrender1:amd64 libfontconfig1:amd64 libxi6:amd64 libstdc++6:amd64 qemu-user-static --no-install-recommends \
    && mkdir /tmp/qemu-amd64 \
    && cp -R /usr/bin/qemu-x86_64* /usr/bin/qemu-amd64* /tmp/qemu-amd64 \
    && rm /usr/bin/qemu-* \
    && mv /tmp/qemu-amd64/* /usr/bin/ \
    && rm -rf /var/lib/apt/lists/* /tmp/qemu-amd64

curl -L https://github.com/h4cc/wkhtmltopdf-amd64/raw/refs/tags/0.12.4/bin/wkhtmltopdf-amd64 -o /usr/local/bin/wkhtmltopdf-amd64

cat > /usr/local/bin/wkhtmltopdf <<'EOF'
#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN_PATH="$SCRIPT_DIR/wkhtmltopdf-amd64"

if [[ "$(uname -m)" == "x86_64" ]]; then
    "$BIN_PATH" "$@"
else
    qemu-amd64-static "$BIN_PATH" "$@"
fi

EOF

chmod +x /usr/local/bin/wkhtmltopdf-amd64 /usr/local/bin/wkhtmltopdf
