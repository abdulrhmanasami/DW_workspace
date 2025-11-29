#!/usr/bin/env python3
import sys
import json


def main():
    # Read stdin line-by-line and extract only Flutter JSON reporter print messages
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        # Skip non-JSON lines (Flutter may emit progress logs)
        if not (line.startswith('{') and line.endswith('}')):
            continue
        try:
            evt = json.loads(line)
        except Exception:
            continue

        # Capture only 'print' events; their 'message' field contains our JSON line
        if evt.get('type') == 'print' and isinstance(evt.get('message'), str):
            msg = evt['message'].strip()
            if msg.startswith('{') and msg.endswith('}'):
                print(msg)
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
import sys
import json


def main():
    # Read flutter test -r json stream from stdin and emit only the printed JSON messages
    for raw in sys.stdin:
        line = raw.strip()
        if not (line.startswith('{') and line.endswith('}')):
            continue
        try:
            evt = json.loads(line)
        except Exception:
            continue
        if evt.get('type') == 'print' and isinstance(evt.get('message'), str):
            msg = evt['message'].strip()
            if msg.startswith('{') and msg.endswith('}'):
                print(msg)
    return 0


if __name__ == "__main__":
    sys.exit(main())

