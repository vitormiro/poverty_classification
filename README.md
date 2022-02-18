# poverty_classification
# Poverty classification using Machine Learning

This project presents an application of the association between machine learning methods and eligibility tests such as proxy means test (PMT). We propose a discussion about the applicability of machine learning models in classifying beneficiaries of poverty reduction programs, assuming the hypothesis that these methods can improve selection mechanisms and improve policy targeting. The empirical exercise carried out uses data from the Continuous PNAD and adjusts a household/family classification model according to their poverty status.

------ 

## 1. Pre requirements 
### 1.1 Poetry 
Poetry helps you declare, manage and install dependencies of Python projects, ensuring you have the right stack everywhere.
O Poetry traz ao Python o tipo de ferramenta de gestão de projetos “all in one” que Go e Rust desfrutam há muito tempo. Permitindo que os projetos tenham dependências determinísticas com versões específicas de pacotes, para que sejam construídos consistentemente em locais diferentes. O Poetry também facilita a criação, o empacotamento e a publicação de projetos e bibliotecas no PyPI, para que outras pessoas possam compartilhar os frutos de seus trabalhos em Python.
The purpose of the **poverty_classification** is to get search results about topics provided by a notification service along with google customsearch

### 1.2 Installing o Poetry
# How to run the app
In order to run succesfully, this app requires some environment variables, which are defined inside the **.env.sample** file. It is possible to either run this app within a docker container, or without the container.

- Linux 
```sh 
curl -sSL \
https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python3 -
```
- Windows 
```sh 
(Invoke-WebRequest -Uri https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py -UseBasicParsing).Content | python -
```
## 2. Files
## To run within the container:
### Requirements:
- Docker

- **pyproject.toml** - Is the specified file format of PEP 518 which contains the build system requirements of Python projects.
- **paper2021** - Folds that contains original python projects that is the starting point for a system of publishing or other processing.


## To run without the container:
### Requirements:
- Poetry

## 3. Starting Project - Local
### 3.1 Cloning the repository
```sh 
git clone https://github.com/vitormiro/poverty_classification.git
```

### 3.2 Installing project dependencies
```sh
sudo poetry install 
```

### 3.3 Running the project
#### 3.3.1 
```sh
poetry run jupyter notebook /poverty-classification/<notebook.ipynb>
```