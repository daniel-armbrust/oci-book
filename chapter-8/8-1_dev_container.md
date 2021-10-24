# Capítulo 8: A aplicação FotoGal

## 8.1 - Desenvolvimento Conteinerizado

### __Visão Geral__

Antes de começar vamos entender o que é _"desenvolvimento conteinerizado"_. 

_Conteinerização_ é um termo usado no qual se refere a ação de _"empacotar o código de um software"_ junto com suas bibliotecas, arquivos de configuração e demais dependências, gerando assim uma _[imagem](https://docs.docker.com/language/python/build-images/)_ que pode ser implantada e executada (deploy) em qualquer infraestrutura que suporte a execução de contêineres. 

_Contêineres_, por serem portáveis e mais eficientes do que _máquinas virtuais (VMs)_ sobre a perspectiva de utilização de recursos, tornaram-se o padrão para desenvolvimento de aplicações modernas e _"nativos da nuvem"_ _[(Cloud Native)](https://en.wikipedia.org/wiki/Cloud_native_computing)_.

Métodos de desenvolvimentos antigos, onde o código era desenvolvido em um ambiente específico e quando era transferido para _"rodar"_ em produção por exemplo, sempre ocasionavam erros, bugs e exigiam diferentes adequações. Uma das grandes vantagens no _"desenvolvimento conteinerizado"_ está na sua _portabilidade_. O contêiner que é usado para desenvolver, é o mesmo usado na produção. O mesmo pacote _auto-contido_ ou _[imagem](https://docs.docker.com/language/python/build-images/)_, pode ser executado em diferentes infraestruturas. Eu posso desenvolver localmente na minha máquina desktop, move e executar no _[OCI](https://www.oracle.com/br/cloud/)_.
