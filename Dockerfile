FROM python:3.7

RUN apt-get update; \
    apt-get install -qq -y --no-install-recommends \
    ca-certificates \
    dirmngr \
    fonts-noto-cjk \
    node-less \
    wkhtmltopdf \
    git \
    build-essential \
    postgresql-common \
	  libsasl2-dev libldap2-dev libssl-dev libpq-dev libjpeg-dev zlib1g-dev libxml2-dev libxslt-dev \
    python3-dev python3-pip

# Mount /var/lib/odoo to allow restoring filestore
VOLUME ["/var/lib/odoo"]

# Create the odoo user
RUN useradd --create-home --home-dir /opt/odoo --no-log-init odoo
USER odoo
WORKDIR /opt/odoo

# Download source code
ENV ODOO_VER 12.0
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/odoo/odoo.git odoo-src
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/l10n-italy.git oca-it
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/account-invoicing.git oca10
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/account-financial-tools.git oca1
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/account-financial-reporting.git oca2
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/account-payment.git oca3
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/partner-contact.git oca4
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/intrastat-extrastat oca5
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/reporting-engine oca6
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/server-tools oca7
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/stock-logistics-workflow oca8
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/server-ux oca9

RUN grep -iRn -A 8 external_dependencies .

# Create requirements.txt for l10n-italy modules
RUN echo "asn1crypto" >> oca-it/requirements.txt
RUN echo "codicefiscale" >> oca-it/requirements.txt
RUN echo "pyxb" >> oca-it/requirements.txt
RUN echo "unicodecsv" >> oca-it/requirements.txt
RUN echo "unidecode" >> oca-it/requirements.txt

# Install dependencies
ENV PATH="/opt/odoo/.local/bin:${PATH}"
RUN pip install --upgrade pip \
 && pip install --upgrade setuptools \
 && pip install wheel \
 && pip install -r odoo-src/requirements.txt \
 && pip install -r oca9/requirements.txt \
 && pip install -r oca-it/requirements.txt

EXPOSE 8069 8071
CMD odoo-src/odoo-bin --db_host db -r odoo -w odoo \
    --addons-path "odoo-src/addons,oca-it,oca1,oca2,oca3,oca4,oca5,oca6,oca7,oca8,oca9,oca10"
