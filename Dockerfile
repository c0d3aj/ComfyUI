FROM nvcr.io/nvidia/pytorch:23.07-py3 as build
RUN set -xe \
    && apt-get update \
    && apt-get install python3-pip python-dev-is-python3 -y
# RUN pip install --no-cache-dir --upgrade pip
RUN python -m pip install --no-cache-dir --upgrade pip setuptools wheel
COPY ./requirements.txt /requirements.txt
# RUN pip install torch torchvision torchaudio torch-tensorrt torchtext --extra-index-url https://download.pytorch.org/whl/cu118 xformers
# RUN pip install llvmlite cython numba

RUN pip install --no-cache-dir -r /requirements.txt
# RUN pip install --upgrade opencv-contrib-python opencv-python
WORKDIR /usr/app
COPY ./.git ./.git
COPY ./web ./web
COPY ./comfy ./comfy
COPY ./comfy_extras ./comfy_extras
COPY ./custom_nodes ./custom_nodes
COPY ./notebooks ./notebooks
COPY ./script_examples ./script_examples
COPY ./input ./input
COPY ./output ./output
COPY ./models ./models
COPY *.py ./
RUN find custom_nodes -type f -name "prestartup_script.py" -exec python {} \;
RUN find custom_nodes -type f -name "requirements.txt" -exec pip install -r {} \;

## Build final image with "BAD_NODES"
RUN git clone https://github.com/WASasquatch/was-node-suite-comfyui ./custom_nodes/was-node-suite-comfyui \
    && pip install -r ./custom_nodes/was-node-suite-comfyui/requirements.txt \
    && git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack ./custom_nodes/ComfyUI-Impact-Pack \
    && find custom_nodes -type f -name "prestartup_script.py" -exec python {} \; \
    && git clone -b tile_preprocessor https://github.com/c0d3aj/comfyui_controlnet_aux ./custom_nodes/comfyui_controlnet_aux \
    && pip install timm==0.6.13

FROM nvcr.io/nvidia/pytorch:23.07-py3 as runtime
WORKDIR /usr/app
COPY --from=build /usr/local/lib/python3.10/dist-packages /usr/local/lib/python3.10/dist-packages
COPY --from=build /usr/app /usr/app
CMD ["python", "main.py", "--listen", "--enable-cors-header"]