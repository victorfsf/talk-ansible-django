# PS: Untested code

# Variables
PROJECT_PATH=/home/victor/app
USWGI_SITES=/etc/uwsgi/sites
UWSGI_SOCKETS=/run/uwsgi

# Update and upgrade packages
sudo apt install -y update
sudo apt install -y upgrade
# Install dependencies
sudo apt install -y git \
	python \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    nginx

# Clone project
git clone git@github.com:victorfsf/talk-ansible-django.git app
# Go to the project's path
cd $PROJECT_PATH

# Check if there's a virtualenv
if [[ ! -f venv/bin/activate ]]; then
	# If there's no venv, create one
	python3 -m venv venv
fi
# Source the virtualenv
source venv/bin/activate
# Install requirements
pip install -r requirements.py

# Run the django migrations and collectstatic
python manage.py migrate
python manage.py collectstatic
# Create the superuser with the pre-configured credentials
python manage.py shell -c "$(cat createsuperuser.py)"

# Make the uWSGI folders
mkdir -p $USWGI_SITES
mkdir -p $UWSGI_SOCKETS
# Copy the uWSGI site file
cp uwsgi-app.ini $UWSGI_SITES/app.ini

# Copy the app service file
cp app.service /etc/systemd/system/djangoapp.service

# Reload the systemd daemon
sudo systemctl daemon-reload
# Enable the app to start when the system starts
sudo systemctl enable djangoapp
# Restart the app
sudo systemctl restart djangoapp

# Copy the nginx config file to nginx's sites-available folder
cp nginx-app /etc/nginx/sites-available/app
# Check nginx syntax
nginx -t
# Link sites-available with sites-enabled
ln -s /etc/nginx/sites-available/app /etc/nginx/sites-enabled/app

# Enable nginx to start when the system starts
sudo systemctl enable nginx
# Restart nginx to apply changes
sudo systemctl restart nginx
