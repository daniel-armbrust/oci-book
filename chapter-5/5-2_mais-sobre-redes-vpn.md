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

Seu propósito é criar _"túneis criptografados"_ entre dois pontos autorizados que neste caso são um data center local _(on-premises)_ e o _[OCI](https://www.oracle.com/cloud/)_. Este _"túnel criptografado"_ mantém os dados que trafegam, seguros e confiáveis, através de técnicas de criptografia. Usa-se a internet por ser financeiramente mais barato do que adquirir links de dados dedicados.

Basicamente existem dois tipos de _[VPN](https://pt.wikipedia.org/wiki/Rede_privada_virtual)_:

- _[Client-To-Site (Host-To-Network)](https://pt.wikipedia.org/wiki/Rede_privada_virtual#Tipos)_ ou _[Remote Access](https://pt.wikipedia.org/wiki/Rede_privada_virtual#Tipos)_
- _[Site-To-Site (Router-To-Router)](https://pt.wikipedia.org/wiki/Rede_privada_virtual#Tipos)_

 Aqui, iremos nos concentrar na _[VPN](https://pt.wikipedia.org/wiki/Rede_privada_virtual)_ do tipo _[Site-To-Site](https://pt.wikipedia.org/wiki/Rede_privada_virtual#Tipos)_, pois nosso objetivo é conectar a rede de um _data center (Network-A)_ ao _[OCI](https://www.oracle.com/cloud/) (Network-B)_. 

![alt_text](./images/data_a_cloud_b_1.jpg "VPN Site-To-Site")

O _[OCI](https://www.oracle.com/cloud/)_ disponibiliza o serviço _[VPN Site-to-Site](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/overviewIPsec.htm)_, que nada mais é do que um serviço gerenciado pela própria Oracle e que utiliza o protocolo _[IPSec](https://pt.wikipedia.org/wiki/IPsec)_ para a construção de _[VPNs](https://pt.wikipedia.org/wiki/Rede_privada_virtual)_.

### __Falando um pouco sobre IPSec__

_[Internet Protocol Security](https://pt.wikipedia.org/wiki/IPsec)_ ou _[IPSec](https://pt.wikipedia.org/wiki/IPsec)_, é um conjunto de protocolos que basicamente autêntica e criptografa os pacotes de dados trocados entre duas redes _(Network A e B)_. O tráfego IP é criptografado antes que os pacotes sejam transferidos da origem para o destino, e descriptografados quando ele chega.

O _[IPSec](https://pt.wikipedia.org/wiki/IPsec)_ pode ser configurado a partir de um dos modos abaixo:

- **Modo de Transporte (Transport mode)**
    - O _[IPSec](https://pt.wikipedia.org/wiki/IPsec)_ criptografa e autêntica somente o _payload do pacote (dados)_. Informações contidas no cabeçalho do pacote não são alteradas.

- **Modo Túnel (Tunnel mode)**
    - Aqui o _[IPSec](https://pt.wikipedia.org/wiki/IPsec)_ criptografa e autêntica todo o pacote. Após isto, o pacote original já com seus dados criptografados, é colocado dentro de um novo pacote gerado (pacote original é encapsulado em um novo pacote).

Além de ser o mais seguro, o _"Modo Túnel"_  é o único suportado pelo _[OCI](https://www.oracle.com/cloud/)_.

### Conectando meu data center ao OCI

Existem vários dispositivos ou softwares existentes no mercado no qual é possível ser utilizado para realizar conectividade via _[VPN](https://pt.wikipedia.org/wiki/Rede_privada_virtual)_ ao _[OCI](https://www.oracle.com/cloud/)_. A _Oracle_ testa, verifica e disponibiliza, todo o passo a passo de configuração por dispositivo ou software, de diversos fabricantes diferentes neste _[link aqui](https://docs.oracle.com/pt-br/iaas/Content/Network/Reference/CPElist.htm)_.

Neste nosso exemplo, iremos demonstrar a configuração do software _[Libreswan](https://libreswan.org/)_ em um servidor _[Oracle Linux](https://www.oracle.com/linux/)_ localizado em um data center qualquer (on-premises).

_[Libreswan](https://libreswan.org/)_ é uma implementação do protocolo _[IPSec](https://pt.wikipedia.org/wiki/IPsec)_ de _[código aberto](https://en.wikipedia.org/wiki/Open_source)_, baseado no _[FreeS/WAN](https://www.freeswan.org/)_ e _[Openswan](https://www.openswan.org/)_. Para este nosso exemplo, será necessário:

- **Libreswan >= 3.18**
- **Linux Kernel 3.x ou 4.x**

>_**__NOTA:__** Iremos utilizar em nosso data center fictício, o [Oracle Linux versão 7.9](https://docs.oracle.com/en/operating-systems/oracle-linux/7/relnotes7.9/index.html), pois ele já contempla as versões de software que precisamos._ 


