# Capítulo 2: Automação, Arquitetura e DevOps

## 2.8 - Uma breve apresentação sobre Modelos de Arquitetura

### Modelo de 3 Camadas

É o modelo mais conhecido onde consiste em uma _Camada de Apresentação (interface com o usuário)_, _Camada de Aplicação (regras de negócio)_ e _Camada de Banco de Dados_.

![alt_text](./images/arch-model-3-tier.jpg  "Modelo de 3 Camadas")

Muitas aplicações do _[mundo corporativo (enterprise)](https://en.wikipedia.org/wiki/Enterprise_software)_ foram criadas sobre este modelo onde tínhamos, um _[Apache](https://pt.wikipedia.org/wiki/Servidor_Apache) ou [Nginx](https://pt.wikipedia.org/wiki/Nginx)_ fazendo papel de _[proxy reverso](https://pt.wikipedia.org/wiki/Proxy_reverso)_ e ficando a frente de um _[servidor de aplicação (middleware)](https://pt.wikipedia.org/wiki/Servidor_de_aplica%C3%A7%C3%A3o)_ _[Jboss](https://en.wikipedia.org/wiki/JBoss_Enterprise_Application_Platform)_ ou _[Tomcat](https://pt.wikipedia.org/wiki/Apache_Tomcat)_, que era o local onde a aplicação era executada e _implantada (deploy)_. Este _[servidor de aplicação](https://pt.wikipedia.org/wiki/Servidor_de_aplica%C3%A7%C3%A3o)_ também tinha acesso a um Banco de Dados para recuperar e persistir as informações, que era normalmente um _[Banco de Dados Oracle](https://pt.wikipedia.org/wiki/Oracle_(banco_de_dados))_ ou _[MySQL](https://pt.wikipedia.org/wiki/MySQL)_.

Apesar de ainda ser um modelo ainda em uso, pode-se dizer que este é um modelo desatualizado neste _"tempo de cloud"_ em que vivemos. Crescer uma aplicação dentro deste modelo ou escalar verticalmente, torna-se difícil e complexo. 

Aplicações executadas sobre este modelo são chamadas de _[aplicações monolíticas](https://pt.wikipedia.org/wiki/Aplica%C3%A7%C3%A3o_monol%C3%ADtica)_.

Com a chegada e maior utilização da _[Computação em Nuvem](https://pt.wikipedia.org/wiki/Computa%C3%A7%C3%A3o_em_nuvem)_, outros modelos de arquiteturas surgiram e passaram a ser utilizados.

### Arquitetura em Microsserviços 

Atualmente o tema de maior destaque, quando falamos ou pensamos no desenvolvimento de software moderno, são os _microsserviços_. Seu conceito é bem simples: _"divida seu aplicativo em partes menores, cada uma desempenhando uma única função e podendo ser desenvolvido e implantado de forma independente."_

Toda parte que foi _"quebrada"_ ou dividia em uma parte menor, recebe o nome de _serviço_. Sendo um _serviço menor_, _auto-contido_ e independente, este passa a ser chamado de _microsserviço_. Pode-se dizer também, que _microsserviços_ é um estilo arquitetural que estrutura uma aplicação em uma _"coleção de serviços"_. Cada diferente serviço é independente de linguagem de programação. Você pode ter serviços escritos em _[Python](https://pt.wikipedia.org/wiki/Python)_, _[Go](https://pt.wikipedia.org/wiki/Go_(linguagem_de_programa%C3%A7%C3%A3o))_ ou _[Java](https://pt.wikipedia.org/wiki/Java_(linguagem_de_programa%C3%A7%C3%A3o))_, coexistindo juntos.

Utilizar este estilo de arquitetura não resolve todos os problemas (não é uma _"bala de prata"_). Seu uso somente é recomendando quando começam haver problemas de escalabilidade, tanto no código, pessoas e infraestrutura. 

Podemos destacar algumas vantagens e desvantagens deste estilo arquitetural:

- **Vantagens**
    - Escalabilidade.
    - Melhor utilização dos recursos.
    - Isolamento de Falhas 
        - Se um serviço _"cai"_ somente este serviço em particular para de funcionar, não afetando o resto da aplicação.
    - Deploy parcial.
    - Equipes distintas focadas no desenvolvimento, melhorias e sustentação de cada serviço em separado.    
    - Agnóstico de tecnologia 
        - Você pode ter _microsserviços_ escritos em _[Python](https://pt.wikipedia.org/wiki/Python)_, _[Go](https://pt.wikipedia.org/wiki/Go_(linguagem_de_programa%C3%A7%C3%A3o))_, _[Java](https://pt.wikipedia.org/wiki/Java_(linguagem_de_programa%C3%A7%C3%A3o))_ ou qualquer outra linguagem que quiser.

- **Desvantagens**
    - Desenvolvimento trabalhoso
    - Complexidade operacional de manter tudo funcionando é maior
    - Orquestração dos serviços (como é feito o deploy de todos ou parcial)
    - Chamadas remotas podem ser lentas (maior dependência da rede e comunicação entre máquinas)
    - Service Discovery (como que cada microsserviço passa a descobrir outros microsserviços)
    - Controle de versão entre serviços