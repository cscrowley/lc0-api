cat <<EOF > README.md
# Lc0 API (Serverless)

A lightweight serverless-ready REST API for [Leela Chess Zero (Lc0)](https://lczero.org/), built with Flask and Docker.

## 🔧 API Endpoint

**POST** `/bestmove`

**JSON Body:**
\`\`\`json
{
  "fen": "r1bqkbnr/pppppppp/n7/8/8/N7/PPPPPPPP/R1BQKBNR w KQkq - 0 1"
}
\`\`\`

**Response:**
\`\`\`json
{
  "bestmove": "e2e4"
}
\`\`\`

## 🚀 Run Locally

\`\`\`bash
docker build -t lc0-api .
docker run --gpus all -p 5000:5000 lc0-api
\`\`\`

## ☁️ Deploy on RunPod Serverless

1. Zip project folder.
2. Upload to RunPod Serverless Endpoint.
3. Select GPU (e.g., T4) + Dockerfile support.
4. POST to \`/bestmove\`.
EOF
