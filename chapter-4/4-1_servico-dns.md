# Capítulo 4: Melhorias na aplicação Wordpress

## 4.1 - Utilizando o Serviço de DNS

### __Visão Geral__

Ao iniciarmos a migração ou hospedagem, dos nossos ativos computacionais para o _[OCI](https://www.oracle.com/cloud/)_, nos deparamos com um serviço simples porém extremamente crítico - o _[DNS](https://pt.wikipedia.org/wiki/Sistema_de_Nomes_de_Dom%C3%ADnio)_.

Neste capítulo irei explicar um pouco da teoria por trás do _[DNS (Domain Name System)](https://pt.wikipedia.org/wiki/Sistema_de_Nomes_de_Dom%C3%ADnio)_ ou _[Sistema de Nomes de Domínio](https://pt.wikipedia.org/wiki/Sistema_de_Nomes_de_Dom%C3%ADnio)_, além de demonstrar como migrar um domínio para ser gerenciado pelo _[Serviço de DNS](https://docs.oracle.com/pt-br/iaas/Content/DNS/Concepts/dnszonemanagement.htm)_ do _[OCI](https://www.oracle.com/cloud/)_.

No capítulo anterior reservamos o _[endereço IP público](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingpublicIPs.htm#Public_IP_Addresses)_ _152.70.221.188_ para a aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_. Todo o acesso por enquanto está sendo feito por este IP. 

Ao final deste capítulo, a aplicação será acessada por um nome.

Vamos lá ...

### __O que é DNS?__

O _[DNS ou Domain Name System (Sistema de Nomes de Domínios)](https://pt.wikipedia.org/wiki/Sistema_de_Nomes_de_Dom%C3%ADnio)_ é um tipo de banco de dados distribuído que contém informações de _[hosts](https://pt.wikipedia.org/wiki/Host)_. Sua principal função é resolver (traduzir ou mapear) um nome de host em seu respectivo endereço IP.

Lembrando que a comunicação entre máquinas na Internet, ocorre através de _[endereços IPs](https://pt.wikipedia.org/wiki/Endere%C3%A7o_IP)_. Os nomes existem para facilitar a identificação ou acesso de uma máquina, por nós humanos.

Este banco de dados de hosts, que forma o _[serviço DNS](https://docs.oracle.com/pt-br/iaas/Content/DNS/Concepts/dnszonemanagement.htm)_, é representado por uma **_árvore invertida_** no qual possui uma única raiz (root) no topo: