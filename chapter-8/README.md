# Conhecendo o OCI (Oracle Cloud Infraestructure)

## Capítulo 8: A aplicação FotoGal

_FotoGal (Foto Galeria)_ é uma aplicação _[Web/Cloud Native](https://en.wikipedia.org/wiki/Cloud_native_computing)_ escrita em _[Python](https://www.python.org/)_ e que usa o framework _[Flask](https://flask.palletsprojects.com)_. A aplicação é uma _["prova de conceito" (PoC - proof of concept (PoC)](https://en.wikipedia.org/wiki/Proof_of_concept)_ que imita algumas características básicas da aplicação _[Instagram](https://pt.wikipedia.org/wiki/Instagram)_ sobre os serviços disponíveis no _[OCI](https://www.oracle.com/br/cloud/)_.

![alt_text](./images/fotogal-logo.jpg "FotoGal")

Por enquanto, a aplicação utiliza os seguintes serviços do _[OCI](https://www.oracle.com/br/cloud/)_:

- [Object Storage](https://docs.oracle.com/pt-br/iaas/Content/Object/Concepts/objectstorageoverview.htm)
- [Banco de Dados NoSQL](https://docs.oracle.com/pt-br/iaas/nosql-database/index.html)
- [Log](https://docs.oracle.com/pt-br/iaas/Content/Logging/Concepts/loggingoverview.htm)
- [Container Engine for Kubernetes](https://docs.oracle.com/pt-br/iaas/Content/ContEng/Concepts/contengoverview.htm)
- [Load Balancing](https://docs.oracle.com/pt-br/iaas/Content/Balance/Concepts/balanceoverview.htm)

A tendência, com o tempo, é aumentar as funcionalidades da aplicação através da utilização de mais serviços.

[8.1 - Recursos da Aplicação](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-8/8-1_fotogal-resources.md) <br>
[8.2 - Introdução ao Serviço Container Engine for Kubernetes](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-8/8-2_intro-oke.md) <br>