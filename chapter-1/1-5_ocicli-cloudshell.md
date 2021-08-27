# Capítulo 1: Conceitos e introdução a Computação em Nuvem no OCI

## 1.5 - OCI CLI e Cloud Shell

### __OCI CLI__

A Computação em Nuvem não existe sem automação! Por conta disto, a Oracle disponibiliza algumas ferramentas que facilitam a interação com as APIs do OCI. Lidar diretamente com as APIs exige detalhes e é trabalhoso. 

Este é um livro _"Orientado a Código"_. Poucas vezes iremos utilizar a _[Web Console](https://docs.oracle.com/pt-br/iaas/Content/GSG/Tasks/signingin.htm#Signing_In_to_the_Console)_ para exibir ou concluir uma ação. A _[Web Console](https://docs.oracle.com/pt-br/iaas/Content/GSG/Tasks/signingin.htm#Signing_In_to_the_Console)_ está sujeita a sofrer mudanças com maior frequência, sendo que isto poderia invalidar nossos exemplos aqui. 

O _[OCI CLI](https://docs.oracle.com/pt-br/iaas/Content/API/Concepts/cliconcepts.htm)_ é uma ferramenta de linha de comando que permite você interagir, de um modo mais fácil, com a Oracle Cloud. O _[OCI CLI](https://docs.oracle.com/pt-br/iaas/Content/API/Concepts/cliconcepts.htm)_ fornece mais funcionalidades que a _[Web Console](https://docs.oracle.com/pt-br/iaas/Content/GSG/Tasks/signingin.htm)_.

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

É sempre bom verificarmos se realmente estamos utilizando a última versão disponível do OCI CLI.

```
darmbrust@hoodwink:~$ oci --latest-version
3.0.1
You are using OCI CLI version 2.26.2, however version 3.0.1 is available. 
You should consider upgrading using https://docs.cloud.oracle.com/en-us/iaas/Content/API/SDKDocs/cliupgrading.htm
```

### __Cloud Shell__

Cloud Shell: A CLI é pré-configurada com suas credenciais e pronta para ser usada imediatamente no Cloud Shell.