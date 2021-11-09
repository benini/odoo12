FROM debian:buster

RUN apt-get update; \
    apt-get install -qq -y --no-install-recommends \
    ca-certificates \
    dirmngr \
    fonts-noto-cjk \
    node-less \
    wget \
    git \
    build-essential \
    postgresql-client-11 \
	  libsasl2-dev libldap2-dev libssl-dev libpq-dev libjpeg-dev zlib1g-dev libxml2-dev libxslt-dev \
    python3.7-dev python3-pip

RUN wget -q https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb -O /tmp/wkhtml.deb
RUN apt install -y /tmp/wkhtml.deb

# Create the odoo user
RUN useradd --create-home --home-dir /opt/odoo --no-log-init odoo
USER odoo
WORKDIR /opt/odoo

# Download source code
ENV ODOO_VER 12.0
RUN git clone --depth 1000 --branch ${ODOO_VER} https://github.com/odoo/odoo.git odoo-src \
&& cd odoo-src \
&& git reset --hard `git rev-list -n 1 --first-parent --before=2021-01-24 HEAD` \
&& git clean -fdx && git log -n 1 \
&& cd ..

RUN git clone --depth 1000 --branch ${ODOO_VER} https://github.com/OCA/l10n-italy.git oca-it \
&& cd oca-it \
&& git reset --hard `git rev-list -n 1 --first-parent --before=2021-01-24 HEAD` \
&& git clean -qfdx && git log -n 1 \
&& cd ..

RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/account-closing.git oca1a \
&& git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/account-invoicing.git oca2a \
&& git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/account-financial-tools.git oca3a \
&& git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/account-financial-reporting.git oca4a \
&& git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/account-payment.git oca5a

RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/partner-contact.git oca1
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/reporting-engine oca2
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/server-tools oca3
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/server-ux oca4
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/web oca5
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/intrastat-extrastat oca6
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/stock-logistics-workflow oca7
RUN git clone --depth 1 --branch ${ODOO_VER} https://github.com/OCA/bank-statement-import oca8

RUN grep -iRn -A 8 external_dependencies .

# Fix: matplotlib 3.3.3 has requirement pillow>=6.2.0, but you'll have pillow 6.1.0 which is incompatible.
RUN sed -i "s/Pillow==6.1/Pillow==6.2/g" odoo-src/requirements.txt

# Create requirements.txt for l10n-italy modules
RUN echo "asn1crypto" >> oca-it/requirements.txt
RUN echo "codicefiscale" >> oca-it/requirements.txt
RUN echo "pyxb" >> oca-it/requirements.txt
RUN echo "unicodecsv" >> oca-it/requirements.txt
RUN echo "unidecode" >> oca-it/requirements.txt
RUN echo "phonenumbers" >> oca-it/requirements.txt

# Install dependencies
ENV PATH="/opt/odoo/.local/bin:${PATH}"
RUN pip3 install --upgrade "setuptools<58" \
 && pip3 install --upgrade wheel \
 && pip3 install -r odoo-src/requirements.txt \
 && pip3 install -r oca-it/requirements.txt \
 && pip3 install -r oca3a/requirements.txt \
 && pip3 install -r oca1/requirements.txt \
 && pip3 install -r oca2/requirements.txt \
 && pip3 install -r oca3/requirements.txt \
 && pip3 install -r oca4/requirements.txt \
 && pip3 install -r oca5/requirements.txt

# Mount odoo data_dir
RUN mkdir -p /opt/odoo/volume/odoo_data_dir
VOLUME ["/opt/odoo/volume"]

RUN echo "[options]" >> /opt/odoo/.odoorc
RUN echo "addons_path = /opt/odoo/odoo-src/addons,/opt/odoo/oca-it,/opt/odoo/oca1a,/opt/odoo/oca2a,/opt/odoo/oca3a,/opt/odoo/oca4a,/opt/odoo/oca5a,/opt/odoo/oca1,/opt/odoo/oca2,/opt/odoo/oca3,/opt/odoo/oca4,/opt/odoo/oca5,/opt/odoo/oca6,/opt/odoo/oca7,/opt/odoo/oca8" >> /opt/odoo/.odoorc
RUN echo "data_dir = /opt/odoo/volume/odoo_data_dir" >> /opt/odoo/.odoorc
RUN echo "db_host = db" >> /opt/odoo/.odoorc
RUN echo "db_user = odoo" >> /opt/odoo/.odoorc
RUN echo "db_password = odoo" >> /opt/odoo/.odoorc

EXPOSE 8069 8071
CMD odoo-src/odoo-bin
