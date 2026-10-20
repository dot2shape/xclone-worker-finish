# x-clone 마감 모델 실험 워커 — ComfyUI 서버리스 베이스 + IP-Adapter(FaceID) 커스텀 노드
# 모델은 Runpod 네트워크 볼륨(/runpod-volume/models/...)에 둔다. 이미지에는 노드·의존성만.
FROM runpod/worker-comfyui:5.10.0-base

# IP-Adapter plus (FaceID 포함)
RUN comfy-node-install comfyui_ipadapter_plus

# FaceID 의존성: insightface 는 소스 빌드 — 베이스는 apt python3.12 + uv venv(/opt/venv) 이므로
# python3.12-dev(Python.h)·빌드 도구를 넣고, Cython·numpy 선설치 후 빌드 격리 없이 같은 venv 에 설치한다
RUN apt-get update && apt-get install -y --no-install-recommends python3.12-dev build-essential cmake g++ \
 && rm -rf /var/lib/apt/lists/* \
 && uv pip install --no-cache-dir "cython<3.1" numpy setuptools wheel \
 && uv pip install --no-cache-dir --no-build-isolation "insightface==0.7.3" \
 && uv pip install --no-cache-dir onnxruntime-gpu onnxruntime opencv-python-headless \
 && python -c "import insightface, onnxruntime; print('insightface', insightface.__version__, 'ort', onnxruntime.__version__)"

# 볼륨 모델 경로 확장(style_models·ipadapter·insightface) — 기본 yaml 덮어쓰기
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml
