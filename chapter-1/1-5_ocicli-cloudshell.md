# Capítulo 1: Conceitos e introdução a Computação em Nuvem no OCI

## 1.5 - OCI CLI e Cloud Shell

### __OCI CLI__

A Computação em Nuvem não existe sem automação! Por conta disto, a Oracle disponibiliza algumas ferramentas que facilitam a interação com as APIs do OCI. Lidar diretamente com as APIs exige detalhes e é trabalhoso. 

Este é um livro _"Orientado a Código"_. Poucas vezes iremos utilizar a _[Web Console](https://docs.oracle.com/pt-br/iaas/Content/GSG/Tasks/signingin.htm#Signing_In_to_the_Console)_ para exibir ou concluir uma ação. A _[Web Console](https://docs.oracle.com/pt-br/iaas/Content/GSG/Tasks/signingin.htm#Signing_In_to_the_Console)_ está sujeita a sofrer mudanças com maior frequência, sendo que isto poderia invalidar nossos exemplos aqui. 

O _[OCI CLI](https://docs.oracle.com/pt-br/iaas/Content/API/Concepts/cliconcepts.htm)_ é uma ferramenta de linha de comando que permite você interagir, de um modo mais fácil, com as APIs do OCI. O _[OCI CLI](https://docs.oracle.com/pt-br/iaas/Content/API/Concepts/cliconcepts.htm)_ fornece mais funcionalidades que a _[Web Console](https://docs.oracle.com/pt-br/iaas/Content/GSG/Tasks/signingin.htm)_.

A referência completa de todos os comandos do OCI CLI pode ser vista _[aqui](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/)_.

#### __Instalação do OCI CLI__

A instalação do OCI CLI é muito simples. Irei apresentar os comandos usados para instalação em um sistema operacional Linux. Para saber sobre outros sistemas operacionais suportados, consulte a documentação oficial _[aqui](https://docs.oracle.com/pt-br/iaas/Content/API/SDKDocs/cliinstall.htm)_.

```
root@hoodwink:~# bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 17280  100 17280    0     0  36150      0 --:--:-- --:--:-- --:--:-- 36150
...
```

O comando acima tenta resolver sozinho diversas dependências para concluir a instalação, caso seja necessário.

#### __Atualizando o OCI CLI__

É sempre bom verificarmos se realmente estamos utilizando a última versão disponível do _[OCI CLI](https://docs.oracle.com/pt-br/iaas/Content/API/Concepts/cliconcepts.htm)_.

```
root@hoodwink:~# oci --latest-version
3.0.2
You are using OCI CLI version 2.26.2, however version 3.0.2 is available. 
You should consider upgrading using https://docs.cloud.oracle.com/en-us/iaas/Content/API/SDKDocs/cliupgrading.htm
```

Neste caso, o comando nos avisou que há a necessidade de atualização. Para atualizar, executamos o comando abaixo:

```
root@hoodwink:~# pip install oci-cli --upgrade
```

Feito! Podemos verificar que a ferramenta foi atualizada pois agora não há nenhum aviso:

```
root@hoodwink:~# oci --latest-version
3.0.2
```

Mantenha-se sempre atualizado! Além de corrigir bugs e acrescentar melhorias, atualizar o _[OCI CLI](https://docs.oracle.com/pt-br/iaas/Content/API/Concepts/cliconcepts.htm)_ possibilita interação com novos serviços.

### __Cloud Shell__

O _[Cloud Shell](https://docs.oracle.com/pt-br/iaas/Content/API/Concepts/devcloudshellintro.htm)_ é um terminal (shell Linux) acessível através da _[Web Console](https://docs.oracle.com/pt-br/iaas/Content/GSG/Tasks/signingin.htm#Signing_In_to_the_Console)_, gratuito e já com o _[OCI CLI](https://docs.oracle.com/pt-br/iaas/Content/API/Concepts/cliconcepts.htm)_ configurado e pronto pra uso. Há também outras ferramentas que já vem instaladas como o _[Ansible](https://docs.oracle.com/pt-br/iaas/Content/API/SDKDocs/ansible.htm)_.

>_**__NOTA:__** A lista das ferramentas disponíveis no [Cloud Shell](https://docs.oracle.com/pt-br/iaas/Content/API/Concepts/devcloudshellintro.htm) pode ser consultada na documentação oficial [aqui](https://docs.oracle.com/pt-br/iaas/Content/API/Concepts/devcloudshellintro.htm#Whats_Included_With_Cloud_Shell)._

O _[Cloud Shell](https://docs.oracle.com/pt-br/iaas/Content/API/Concepts/devcloudshellintro.htm)_ pode ser uma maneira rápida e prática para utilização do _[OCI CLI](https://docs.oracle.com/pt-br/iaas/Content/API/Concepts/cliconcepts.htm)_, sem a necessidade de seguir o processo de instalação. Para iniciar o uso, basta clicar no seu botão localizado no topo da console:



