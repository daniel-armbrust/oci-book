# Capítulo 4: Primeira aplicação no OCI

## 4.5 - Introdução ao Serviço de Load Balancer

### __Introdução__

_Load Balancer_, _Balanceador de Carga_ ou _LBaaS_ são alguns nomes que identificam o _[Serviço de Load Balancing](https://docs.oracle.com/pt-br/iaas/Content/Balance/Concepts/balanceoverview.htm)_ disponível no _[OCI](https://www.oracle.com/cloud/)_.

Sua principal função é realizar a distribuição do tráfego de um ponto de entrada, para vários servidores existentes em sua _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_. Além de distribuir a _"carga de trabalho"_ entre duas ou mais intâncias de computação, temos uma melhor utilização dos recursos, possibilidade de escalonamento e alta disponibilidade.

Abaixo iremos listar algumas propriedades e características do serviço que serão úteis quando formos criar o nosso:

- **Público ou Privado**
    - Um balanceador de carga _**público**_ é criado em uma subrede pública com endereço IP público e acessível pela internet. Este pode ser criado em uma subrede regional no qual irá consumir dois endereços IPs privados, ou pode ser criado em duas subredes públicas sobre dois _[ADs](https://docs.oracle.com/pt-br/iaas/Content/General/Concepts/regions.htm#About)_ diferentes, consumindo dois endereços IPs privados por _[ADs](https://docs.oracle.com/pt-br/iaas/Content/General/Concepts/regions.htm#About)_.
   - Já um balancedor de carga _**privado**_ é criado em uma subrede privada com o intuito de não receber requisições pela internet, e fazer _"frente"_ somente com recursos internos. Neste caso será consumido três endereços IPs privados da subrede.
    - Em ambos, há um endereço IP principal que possui a característica de ser _"flutuante"_. Ou seja, ele se alternará para o balanceador de carga secundário (standby) em caso de falha no principal.

- **Listener**
    - Você configura um _**listener**_ para tratar conexões através dos protocolos de _[Camada 7](https://pt.wikipedia.org/wiki/Camada_de_aplica%C3%A7%C3%A3o)_ (_[HTTP](https://pt.wikipedia.org/wiki/Hypertext_Transfer_Protocol)_, _[HTTPS](https://pt.wikipedia.org/wiki/Hyper_Text_Transfer_Protocol_Secure)_ ou _[HTTP/2](https://pt.wikipedia.org/wiki/HTTP/2)_) ou _[Camada 4](https://pt.wikipedia.org/wiki/Camada_de_transporte)_ (_[TCP](https://pt.wikipedia.org/wiki/Transmission_Control_Protocol)_) em portas específicas.
    - Você pode definir vários _**listener**_ que tratam um determinado protocolo, porém em portas diferentes.

- **Backends**
    - Um _"conjunto de backend"_ é uma entidade lógica que permite você agrupar recursos ou instâncias de computação, que receberão o tráfego da rede.
     

Uma das formas de empregar a _["alta disponibilidade"](https://en.wikipedia.org/wiki/High_availability)_ através do _[Serviço de Load Balancing](https://docs.oracle.com/pt-br/iaas/Content/Balance/Concepts/balanceoverview.htm)_, se dá pela configuração de políticas de _"Health Check"_, que basicamente realiza testes de forma contínua, com o intuíto de confirmar a disponibilidade _(vivo ou morto)_ dos recursos que estão _"atrás"_ do _[Load Balancer](https://docs.oracle.com/pt-br/iaas/Content/Balance/Concepts/balanceoverview.htm)_.
