FROM nvcr.io/nvidia/pytorch:23.07-py3 as build
RUN set -xe \
    && apt-get update \
    && apt-get install python3-pip python-dev-is-python3 -y
# RUN pip install --no-cache-dir --upgrade pip
RUN python -m pip install --no-cache-dir --upgrade pip setuptools wheel
COPY ./requirements.txt /requirements.txt
# RUN pip install torch torchvision torchaudio torch-tensorrt torchtext --extra-index-url https://download.pytorch.org/whl/cu118 xformers
# RUN pip install llvmlite cython numba
RUN pip install opencv-contrib-python
RUN pip install --no-cache-dir -r /requirements.txt
WORKDIR /usr/app
COPY ./models ./models
COPY ./custom_nodes ./custom_nodes
COPY ./comfy ./comfy
COPY ./comfy_extras ./comfy_extras
COPY ./notebooks ./notebooks
COPY ./input ./input
COPY ./output ./output
COPY ./script_examples ./script_examples
COPY ./web ./web
COPY *.py ./
CMD ["python", "main.py", "--listen", "--enable-cors-header"]