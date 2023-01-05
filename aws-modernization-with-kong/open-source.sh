#This script prepares a zip file of your workshop content and static directory for send through the Open Source approval process.

#zip the necessary files and directories (excluding known template assets)
zip -r workshop.zip workshop/content workshop/static workshop/config.toml README-local.md theme.sh -x workshop/content/shortcodes/attachments/\* workshop/static/images/apn-logo.jpg workshop/static/images/aws-open-source.jpg

echo "workshop.zip is ready for upload to your Open Source SIM."