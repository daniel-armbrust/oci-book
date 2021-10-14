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