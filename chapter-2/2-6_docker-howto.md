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

### O surgimento do Docker

De acordo com a _[documentação oficial do Docker](https://docs.docker.com/get-started/)_, containers não é uma tecnologia nova. Porém, usar contêineres para o deploy de aplicações é algo novo. 

Criado em Março de 2013, o Docker é um conjunto de ferramentas (ferramental) que facilita a criação e administração de contêineres. Ele não é uma tecnologia de virtualização. Ele ajuda a resolver os problemas mais comuns referente a instalação, remoção, atualização e execução de softwares em contêineres. Resolve conflitos relacionados a ambientes de desenvolvimento, eliminando frases do tipo: _"Isto funciona na minha máquina"_.

Podemos dizer que o Docker é um novo formato para _"empacotar"_ aplicações (através de imagens Docker). Qualquer aplicação que _"roda"_ em um terminal Linux, _"roda"_ em Docker.

_"O Docker permite empacotar uma aplicação com todas as suas dependências em uma unidade padronizada, chamado de Imagem Docker."_

_"Docker - Construir, Transportar e Rodar em qualquer lugar."_

### Arquitetura

O Docker usa uma _[arquitetura cliente-servidor](https://pt.wikipedia.org/wiki/Modelo_cliente%E2%80%93servidor)_ e faz uso das tecnologias Linux Namespace e cgroups para prover um _"espaço de trabalho"_ isolado, no qual é chamado de contêiner. Todo o ferramental que o Docker disponibiliza permite a construção e implantação de imagens local ou remotamente.

Alguns dos componentes descritos aqui são:

- **Docker Client (docker)**
    - Programa de linha de comando no qual usa REST API para se comunicar com o Docker Daemon.
    - Ferramenta principal usada pela maioria das pessoas.

- **Docker Daemon (dockerd)**
    - Processo que permanece em execução o tempo todo. Verifica as requisições vindas do cliente para gerenciar os objetos Docker (imagens, contêineres, redes e volumes). Todo o trabalho _"pesado"_ referente a criação, execução e distribuição dos contêineres é feito feito pelo Docker Daemon.
    - Transforma o Linux em um servidor Docker que pode receber ações de um cliente remoto.

- **Docker Image**
    - É uma espécie de template no qual contém instruções para a criação de contêineres.
    - Imagens são usadas para armazenar e transportar aplicações. É uma coleção de arquivos (bibliotecas, executáveis, arquivos de configuração, etc).
    - Você pode criar suas próprias imagens ou baixar imagens criadas por outras pessoas, publicadas em um _[registry](https://en.wikipedia.org/wiki/Docker_(software))_.
    - Uma mesma imagem pode ser copiada para inúmeros hosts.

- **Docker Registry**
    - É um serviço que hospeda repositório(s) de imagen(s), permitindo que tais imagens sejam baixadas pelo comando _"docker pull"_.  
    - Pode ser privado ou público como o Docker Hub.

- **Docker Hub (_[https://hub.docker.com/](https://hub.docker.com/)_)**
    - Repositório oficial de imagens Docker. Nele é possível armazenar suas imagens e torná-las públicas ou privadas.
    - É um serviço acessado através da Internet, que permite você procurar, baixar e compartilhar imagens Docker.

- **Docker Contêiner**
    - É a instância de uma imagem (Docker Image) em execução.
    - É possível criar uma infinidade de contêineres a partir de uma imagem.
    - Você só pode executar processos conteinerizados compatíveis com o Kernel do sistema operacional host. Aplicações Windows não podem ser executadas em contêiner Linux.

- **Dockerfile**
    - É um arquivo texto no qual contém a lista de comandos em forma declarativa (receita) usados para construir uma imagem Docker.
    - Após este arquivo de instruções ser criado, usamos o comando docker build no qual irá de fato criar uma imagem.
  
![alt_text](./images/docker-2.jpg  "Arquitetura Docker") 