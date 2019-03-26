# Cloning and seting up project

*** Before you clone project for the first time: ***

- Create python 2 virtual environment & activate
```sh
virtualenv -p python env
source env/bin/activate
```

- Install requirements
```sh
pip install -r requirements.txt
```


# BDD Test
BDD test using [behave](https://behave.readthedocs.io/en/latest/) and [selenium](http://selenium-python.readthedocs.io/).

To setup, download chromedriver [here](https://sites.google.com/a/chromium.org/chromedriver/downloads) and place it in `/usr/bin` or `/usr/local/bin`.

To run test:

- run all test cases:
```sh
behave
```

- run specific feature file:
```sh
behave -i 01-register.feature
```

- run specific scenario: place the tag `@watch` before specific scenario then run:
```sh
behave -t "@watch"
```
