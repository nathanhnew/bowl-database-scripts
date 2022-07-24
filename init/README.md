# DB Init Scripts
## To run bootstrap issue the following
`
export APP_PASSWORD=$(openssl rand -base64 12)
export ADMIN_PASSWORD=$(openssl rand -base64 12)
psql -v admin_password=$ADMIN_PASSWORD -v app_password=$APP_PASSWORD -a -h localhost -d postgres -U postgres -f user_init.sql
unset APP_PASSWORD
unset ADMIN_PASSWORD
`