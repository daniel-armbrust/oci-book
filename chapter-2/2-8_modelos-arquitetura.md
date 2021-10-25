# Capítulo 2: Automação, Arquitetura e DevOps

## 2.8 - Modelos de Arquitetura

### Modelo de 3 Camadas

É o modelo mais conhecido onde consiste em uma _Camada de Apresentação (interface com o usuário)_, _Camada de Aplicação (regras de negócio)_ e _Camada de Banco de Dados_.

![alt_text](./images/arch-model-3-tier.jpg  "Modelo de 3 Camadas")

Muitas aplicações enterprise foram criadas sobre este modelo onde tínhamos um _[Apache](https://pt.wikipedia.org/wiki/Servidor_Apache) ou [Nginx](https://pt.wikipedia.org/wiki/Nginx)_ fazendo papel de _[proxy reverso](https://pt.wikipedia.org/wiki/Proxy_reverso)_ e ficando a frente de um _[servidor de aplicação (middleware)](https://pt.wikipedia.org/wiki/Servidor_de_aplica%C3%A7%C3%A3o)_ _[Jboss](https://en.wikipedia.org/wiki/JBoss_Enterprise_Application_Platform)_ ou _[Tomcat](https://pt.wikipedia.org/wiki/Apache_Tomcat)_, que era o local onde a aplicação era executada e _implantada (deploy)_. Este _[servidor de aplicação](https://pt.wikipedia.org/wiki/Servidor_de_aplica%C3%A7%C3%A3o)_ também tinha acesso a um Banco de Dados para recuperar e persistir as informações, que era normalmente um _[Banco de Dados Oracle](https://pt.wikipedia.org/wiki/Oracle_(banco_de_dados))_ ou _[MySQL](https://pt.wikipedia.org/wiki/MySQL)_.