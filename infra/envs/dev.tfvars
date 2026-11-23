project          = "acme" # TODO: replace with your project name (lowercase, short)
environment      = "dev"
primary_location = "centralindia"

database = {
  sku_name   = "B_Standard_B1ms"
  storage_mb = 32768
}

frontend = {
  sku_name = "B1"
  image    = "web:latest"
  port     = 3000
}

gateways = {
  main = {
    location = "centralindia"
    sku_name = "B1"
    image    = "gateway:latest"
    port     = 3000
    app_settings = {
      NODE_ENV = "development"
    }
  }
  # To add a gateway, add another entry:
  # second = { location = "centralindia", sku_name = "B2" }
}
