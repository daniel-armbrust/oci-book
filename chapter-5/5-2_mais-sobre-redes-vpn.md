# Capítulo 5: Mais sobre Redes no OCI

## 5.2 - Conexão ao OCI através de VPN

### __Visão Geral__

Hoje em dia sabemos que muitas organizações estão migrando seus ativos computacionais para a Cloud por conta dos inúmeros benefícios que isto agrega. Podemos citar algumas vantagens na sua utilização como:

- A capacidade computacional pode ser ajustada automaticamente conforme demanda (_[Autoscaling](https://en.wikipedia.org/wiki/Autoscaling)_).
- Facilidade em provisionar recursos. Podemos criar servidores físicos (_[Bare Metal](https://www.oracle.com/br/cloud/compute/bare-metal.html)_) e Virtuais, alocar storage, utilizar serviços, tudo de forma ágil e com facilidade.
- Pagamos somente aquilo que usamos (_[Pay As You Go](https://en.wikipedia.org/wiki/Pay-as-you-use)_).
- Foco nos negócios e não mais em detalhes técnicos relacionados à TI.

Sobre as vantagens apresentadas, podemos dizer que a tecnologia deixa de ser uma _"preocupação"_ e se torna um instrumento ágil quando você adere a _[Cloud Computing](https://docs.oracle.com/en/cloud/get-started/subscriptions-cloud/csgsg/oracle-cloud.html)_.

Porém esta transição não acontece do dia para a noite. Iremos exemplificar como podemos conectar um data center qualquer _(on-premises)_ através de uma _[VPN](https://pt.wikipedia.org/wiki/Rede_privada_virtual)_ ao _[OCI](https://www.oracle.com/cloud/)_.

### __O que é uma VPN?__

Uma _[VPN](https://pt.wikipedia.org/wiki/Rede_privada_virtual)_ (_[Virtual Private Network](https://pt.wikipedia.org/wiki/Rede_privada_virtual)_) ou _[Rede privada virtual](https://pt.wikipedia.org/wiki/Rede_privada_virtual)_, é uma rede de comunicação construída sobre uma infraestrutura compartilhada. Para o nosso exemplo, essa infraestrutura compartilhada será um link público de Internet.

Seu propósito é cria _"túneis criptografados"_ entre dois pontos autorizados, que neste caso são um data center local (também chamado de On-Premises) e o _[OCI](https://www.oracle.com/cloud/)_.

Seu objetivo é manter os dados que trafegam entre estes dois pontos, seguros e confiáveis, usando técnicas de criptografia. Usa-se a internet por ser financeiramente mais barato do que adquirir links de dados dedicados.

Basicamente existem dois tipos de VPN:

- _[Client-To-Site (Host-To-Network)](https://pt.wikipedia.org/wiki/Rede_privada_virtual#Tipos)_ ou _[Remote Access](https://pt.wikipedia.org/wiki/Rede_privada_virtual#Tipos)_.
- _[Site-To-Site (Router-To-Router)](https://pt.wikipedia.org/wiki/Rede_privada_virtual#Tipos)_.