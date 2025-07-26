from flask import Flask, request, jsonify
import subprocess
import tempfile

app = Flask(__name__)

@app.route("/bestmove", methods=["POST"])
def bestmove():
    fen = request.json.get("fen")
    if not fen:
        return jsonify({"error": "FEN missing"}), 400

    with tempfile.NamedTemporaryFile("w+", delete=False) as f:
        f.write(f"position fen {fen}\\ngo\\n")
        f.flush()
        try:
            result = subprocess.check_output(
                ["./lc0", "--weights=weights.pb.gz", "--quiet"],
                stdin=open(f.name, "r"),
                stderr=subprocess.STDOUT,
                timeout=15
            )
            result = result.decode("utf-8")
            for line in result.splitlines():
                if line.startswith("bestmove"):
                    move = line.strip().split(" ")[1]
                    return jsonify({"bestmove": move})
        except subprocess.TimeoutExpired:
            return jsonify({"error": "Lc0 timed out"}), 500

    return jsonify({"error": "No move found"}), 500
EOF
