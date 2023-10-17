module github.com/hieuvubk/checker

go 1.16

require (
	github.com/cosmos/cosmos-sdk v0.45.16
	github.com/cosmos/ibc-go/v3 v3.0.0
	github.com/gogo/protobuf v1.3.3
	github.com/golang/protobuf v1.5.3
	github.com/grpc-ecosystem/grpc-gateway v1.16.0
	github.com/ignite-hq/cli v0.22.0
	github.com/spf13/cast v1.5.0
	github.com/stretchr/testify v1.8.2
	github.com/tendermint/spn v0.2.1-0.20220609194312-7833ecf4454a
	github.com/tendermint/tendermint v0.34.27
	github.com/tendermint/tm-db v0.6.7
	golang.org/x/net v0.15.0 // indirect
	google.golang.org/genproto/googleapis/api v0.0.0-20230822172742-b8732ec3820d
	google.golang.org/genproto/googleapis/rpc v0.0.0-20230822172742-b8732ec3820d // indirect
	google.golang.org/grpc v1.58.0
)

replace (
	github.com/99designs/keyring => github.com/cosmos/keyring v1.2.0
	github.com/gogo/protobuf => github.com/regen-network/protobuf v1.3.3-alpha.regen.1
	github.com/tendermint/tendermint => github.com/cometbft/cometbft v0.34.27
	google.golang.org/grpc => google.golang.org/grpc v1.33.2
)
