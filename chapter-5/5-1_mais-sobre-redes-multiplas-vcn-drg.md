# Capítulo 5: Mais sobre Redes no OCI

## 5.1 - Conectando múltiplas VCNs

### __Visão Geral__


Você pode conectar a sua VCN a outra VCN por meio de uma conexão privada que não requer que o tráfego passe pela internet. Em geral, esse tipo de conexão é chamado de pareamento de VCNs.

DYNAMIC ROUTING GATEWAY (DRG) é um roteador virtual 
fornece um caminho para tráfego de rede privada entre a sua VCN e a rede local.
conexão por meio de VPN Site-to-Site ou Oracle Cloud Infrastructure FastConnect.
Ele também pode fornecer um caminho para tráfego de rede privada entre a sua VCN e uma VCN em outra região.


Os blocos CIDR da VCN não devem se sobrepor uns com os outros, com CIDRs na sua rede local ou com os CIDRs da outra VCN com que você parou. Não deve haver sobreposição entre as sub-redes de determinada VCN

Originalmente, as sub-redes foram projetadas para abranger somente um domínio de disponibilidade (AD) em uma região. Elas eram todas específicas do AD

Agora as sub-redes podem ser específicas ou regionais do AD

A Oracle recomenda o uso de sub-redes regionais