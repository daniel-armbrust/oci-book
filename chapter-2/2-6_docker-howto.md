# Capítulo 2: Automação, Arquitetura e DevOps

## 2.6 - Docker HOWTO

### O que é um Contêiner?

Um contêiner é um ambiente de execução completo e isolado (runs in isolation) no qual compartilha o mesmo Kernel do sistema operacional host. Se assemelha a uma máquina virtual por possuir seus próprios processos, serviços, interface de rede, ponto de montagem, etc.  

Executar uma aplicação de forma isolada, dentro de uma mesma máquina, não é algo novo. No _[Linux](https://pt.wikipedia.org/wiki/Linux)_ temos o _[chroot](https://pt.wikipedia.org/wiki/Chroot)_ que restringe o acesso de um processo a uma determinada porção do sistema de arquivos. Vale destacar outras tecnologias existentes a algum tempo como o _[jails](https://pt.wikipedia.org/wiki/FreeBSD_jail)_ do _[FreeBSD](https://pt.wikipedia.org/wiki/FreeBSD)_, e _[Solaris Zones](https://en.wikipedia.org/wiki/Solaris_Containers)_ criado pela _[Sun Microsystems](https://pt.wikipedia.org/wiki/Sun_Microsystems)_. Apesar dessas implementações serem diferentes, elas possuem um objetivo em comum: _"Isolar processos dentro de um mesmo sistema operacional"_

A virtualização no qual conhecemos, no seu sentido mais simples, seria ter sobre um único hardware (host) vários sistemas operacionais (guest), podendo ser de diferentes fabricantes e executados de forma simultânea. Um servidor virtual é criado a partir de um hardware que foi virtualizado ou emulado. 

O conceito de contêineres é similar às máquinas virtuais. A diferença é que as máquinas virtuais _"virtualizam"_ em nível de hardware (diferentes kernel em execução sobre o mesmo hardware). Já os contêineres, possuem virtualização em nível de sistema operacional (um único kernel que executa diferentes aplicações). Normalmente um contêiner executa um único processo dentro dele. E cada contêiner, não sabe da existência um do outro. Contêineres não contém a instalação completa de um Sistema Operacional (apenas alguns binários).

Na imagem abaixo podemos observar melhor essa diferença entre uma máquina tradicional, máquina virtual e contêineres:

![alt_text](./images/docker-1.jpg  "máquina tradicional vs. máquina virtual vs. contêineres")

Pense em um contêiner como sendo uma _"caixa isolada"_ no qual você executa sua aplicação com suas respectivas dependências. É um novo meio para se executar, empacotar e distribuir/transportar suas aplicações.

_"Múltiplas aplicações executadas em um único host, de forma isolada e gerenciadas por um único Kernel."_

### Quais suas vantagens?

Sistemas operacionais completos são difíceis e custosos para uma organização administrar. Imagine vários deles. Mesmo na nuvem ou virtualizados, temos que nos preocupar com segurança, políticas de acesso, usuários, atualizações periódicas, drivers de dispositivos, etc. Além de que, um sistema operacional instalado pode consumir mais de 1 GByte de armazenamento. Sua aplicação completa, não deve passar dos 200 MBytes, na maioria dos casos.

Pelo fato dos contêineres serem ambientes isolados e portáveis, isto ajuda no desenvolvimento de aplicações, pois é possível empacotar uma aplicação com todas suas dependências, formando uma imagem que pode ser transportada para outro servidor, para um desktop ou para a nuvem.

Utilizar contêineres facilita o deploy e execução de aplicações distribuídas. Ao invés de termos um sistema operacional completo para executar uma aplicação, temos um único sistema operacional, um único Kernel, capaz de gerenciar múltiplos contêineres. É a solução que as empresas e desenvolvedores buscam hoje em dia.

_"Menos trabalho e incômodo ao provisionar ambientes de execução (runtime). Ter o mínimo e o essencial para executar uma aplicação."_

Das suas diversas vantagens, podemos destacar:
- Contêineres provêm ambientes isolados (Loose coupling - baixo acoplamento). Mantêm programas e suas dependências isoladas uns dos outros.

- São provisionados, desprovisionados e inicializados muito mais rápidos do que máquinas virtuais.

- Consome menos recursos em termos de hardware, comparados com máquinas virtuais. São mais _"leves"_ e ocupam menos espaço. Permite que as organizações otimizem a utilização de seus recursos de infraestrutura, economizando também custos operacionais.
- Maior eficiência em termos de escalabilidade e desempenho.
- Na maioria dos casos, uma aplicação que _"roda"_ em um contêiner é bastante _"enxuta"_, havendo somente o necessário para o seu funcionamento.
- Facilita o desenvolvimento de Microserviços.
- Aplicações conteinerizadas são portáveis. Tudo que é necessário para _"rodar"_ já está dentro do contêiner e não há dependência externa. Através do conceito de imagens, é possível fazer o deploy em diferentes provedores de Nuvem ou mesmo em ambientes on-premises.
- Possibilita que as aplicações sejam construídas sob o modelo Cloud Native.
- Permite a padronização dos ambientes de desenvolvimento.