# egnd.services

[![Pipeline](https://github.com/egnd/services/workflows/Pipeline/badge.svg)](https://github.com/egnd/services/actions?query=workflow%3APipeline)
[![Release](https://github.com/egnd/services/workflows/Release/badge.svg)](https://github.com/egnd/services/actions?query=workflow%3ARelease)

Set of services for web-hosts handling, logging and monitoring.

### Quick start:
1. Download release from [here](https://github.com/egnd/services/releases)
2. Create a ```.env```-file with ```copy .env.dist .env```
3. Optionally, create a ```docker-compose.override.yml``` in each folder for services params overriding
4. Run with ```make run```
