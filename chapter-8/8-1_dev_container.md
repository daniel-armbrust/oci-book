# Capítulo 8: A aplicação FotoGal

## 8.1 - Desenvolvimento Conteinerizado

### __Visão Geral__

Antes de começar vamos entender o que é _"desenvolvimento conteinerizado"_. 

_Conteinerização_ é um termo usado no qual se refere a ação de _"empacotar o código de um software"_ junto com suas bibliotecas, arquivos de configuração e demais dependências, gerando assim uma _[imagem](https://docs.docker.com/language/python/build-images/)_ que pode ser implantada e executada _(deploy)_ em qualquer infraestrutura que suporte a execução de contêineres _("written once and run anywhere")_. 

_Contêineres_, por serem portáveis e mais eficientes do que _máquinas virtuais (VMs)_, sobre a perspectiva de utilização de recursos, tornaram-se o padrão para desenvolvimento de aplicações modernas e _"nativos da nuvem"_ _[(Cloud Native)](https://en.wikipedia.org/wiki/Cloud_native_computing)_.

Métodos de desenvolvimentos antigos, onde o código era desenvolvido em um ambiente específico e quando era transferido para _"rodar"_ em produção por exemplo, sempre ocasionavam erros, bugs e exigiam diferentes adequações. Uma das grandes vantagens no _"desenvolvimento conteinerizado"_ está na sua _portabilidade_. O contêiner que é usado para desenvolver, é o mesmo usado na produção. O mesmo pacote _auto-contido_ ou _[imagem](https://docs.docker.com/language/python/build-images/)_, pode ser executado em diferentes infraestruturas. Eu posso desenvolver localmente na minha máquina desktop, move e executar no _[OCI](https://www.oracle.com/br/cloud/)_, por exemplo.

>_**__NOTA:__** Para saber mais sobre [Docker](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-2/2-6_docker-howto.md) e seus detalhes, consulte o capítulo [2.6 - Docker HOWTO](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-2/2-6_docker-howto.md)._

Irei apresentar como é desenvolver uma aplicação em _contêiner_ e como realizar o _deploy_ no _[Serviço Container Engine for Kubernetes](https://docs.oracle.com/pt-br/iaas/Content/ContEng/Concepts/contengoverview.htm)_ do _[OCI](https://www.oracle.com/br/cloud/)_. O intuíto não é falar da linguagem de programação _[Python](https://www.python.org/)_ ou do framework _[Flask](https://flask.palletsprojects.com)_, e sim mostrar uma aplicação em execução e que usa os serviços de nuvem do _[OCI](https://www.oracle.com/br/cloud/)_.