FROM ctalapp/ctapipe:latest
MAINTAINER CTA LAPP <cta-pipeline-lapp@in2p3.fr>

ARG CTA_ANALYSIS_CLONE_URL=https://gitlab.in2p3.fr/CTA-LAPP/CTA_Analysis.git
ARG CTA_ANALYSIS_VERSION=master

# Install CTA_Analysis dependencies
RUN source activate cta-dev \
 && conda install -n cta-dev -c menpo eigen \
 && conda install -n cta-dev -c salilab fftw

# Clone CTA_Analysis GIT repository
RUN source activate cta-dev \
 && git clone $CTA_ANALYSIS_CLONE_URL /opt/CTA_Analysis \
 && cd /opt/CTA_Analysis \
 && git checkout $CTA_ANALYSIS_VERSION

# Build and install CTA_Analysis
RUN source activate cta-dev \
 && cd /opt/CTA_Analysis \
 && mkdir build \
 && cd build \
 && cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DRELEASE_MODE=no -DUSE_PYTHON=yes \
 && make -j8 \
 && make install

ENV LD_LIBRARY_PATH=