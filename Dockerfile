FROM ctalapp/ctapipe:latest
MAINTAINER CTA LAPP <cta-pipeline-lapp@in2p3.fr>

ARG CTA_ANALYSIS_CLONE_URL=https://gitlab.in2p3.fr/CTA-LAPP/CTA_Analysis.git
ARG CTA_ANALYSIS_VERSION=master

# Install CTA_Analysis dependencies
RUN source activate ctadev \
 && conda install -n ctadev -c menpo eigen \
 && conda install -n ctadev -c salilab fftw

# Clone CTA_Analysis GIT repository
RUN source activate ctadev \
 && git clone $CTA_ANALYSIS_CLONE_URL /opt/CTA_Analysis \
 && cd /opt/CTA_Analysis \
 && git checkout $CTA_ANALYSIS_VERSION

# Build and install CTA_Analysis
RUN source activate ctadev \
 && cd /opt/CTA_Analysis \
 && mkdir build \
 && cd build \
 && cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DRELEASE_MODE=no -DUSE_PYTHON=yes \
 && make all install \
 && ldconfig
