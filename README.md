# AWS EKS Helm 차트

이 Helm 차트는 AWS EKS 클러스터에서 애플리케이션을 배포하기 위한 템플릿입니다. ALB (Application Load Balancer), Route53 DNS 관리, SSM Parameter Store 통합을 지원합니다.

## 기능

- **AWS EKS 최적화**: EKS 클러스터에서 실행되도록 최적화된 구성
- **ALB 인그레스**: AWS Load Balancer Controller를 통한 ALB 인그레스 지원
- **Route53 통합**: 자동 DNS 레코드 생성 (External-DNS 컨트롤러 사용 또는 직접 설정)
- **SSM Parameter Store**: 환경 변수 및 볼륨으로 AWS Systems Manager Parameter Store 값 사용

## 사전 요구사항

- Kubernetes 1.19+
- Helm 3.2.0+
- AWS EKS 클러스터
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller) 설치
- (선택) [External-DNS](https://github.com/kubernetes-sigs/external-dns) 컨트롤러 설치
- (선택) [Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/) 및 [AWS Provider](https://github.com/aws/secrets-store-csi-driver-provider-aws) 설치

### 차트 설치

```bash
# 기본 설정으로 설치
helm install my-app . -f values.yaml

# 커스텀 값으로 설치
helm install my-app . \
  --set aws.region=ap-northeast-2 \
  --set aws.route53.enabled=true \
  --set aws.route53.zoneName=example.com \
  --set aws.route53.recordName=my-app
```

## 설정 옵션

주요 설정 옵션은 다음과 같습니다:

| 파라미터 | 설명 | 기본값 |
|-----------|-------------|---------|
| `replicaCount` | 애플리케이션 복제본 수 | `1` |
| `image.repository` | 컨테이너 이미지 저장소 | `nginx` |
| `image.tag` | 컨테이너 이미지 태그 | `""` (차트 AppVersion 사용) |
| `aws.region` | AWS 리전 | `us-east-1` |
| `aws.alb.enabled` | ALB 인그레스 활성화 | `false` |
| `aws.route53.enabled` | Route53 DNS 레코드 활성화 | `false` |
| `aws.route53.externalDNS` | External-DNS 컨트롤러 사용 여부 | `false` |
| `aws.route53.zoneName` | Route53 호스팅 영역 이름 | `example.com` |
| `aws.route53.recordName` | DNS 레코드 이름 | `app` |
| `aws.ssmParameterStore.enabled` | SSM Parameter Store 통합 활성화 | `false` |
| `service.type` | Kubernetes 서비스 타입 | `ClusterIP` |
| `ingress.enabled` | 인그레스 리소스 활성화 | `false` |

전체 설정 옵션은 [values.yaml](values.yaml) 파일을 참조하세요.

## AWS 서비스 통합 예제

### ALB 인그레스 설정

```yaml
aws:
  alb:
    enabled: true
    annotations:
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
      alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:123456789012:certificate/abcd1234-abcd-1234-efgh-5678abcd
      alb.ingress.kubernetes.io/healthcheck-path: /health
```

### Route53 DNS 레코드 설정

```yaml
aws:
  route53:
    enabled: true
    externalDNS: false  # External-DNS 컨트롤러를 사용하지 않는 경우
    zoneName: "example.com"
    recordName: "my-app"
    ttl: 300
```

### SSM Parameter Store 통합

```yaml
aws:
  ssmParameterStore:
    enabled: true
    parameters:
      - name: "APP_SECRET"
        path: "/app/production/secret"
      - name: "DB_PASSWORD"
        path: "/app/production/db/password"
```

## 서비스 계정 IAM 역할 연결

EKS 서비스 계정에 IAM 역할을 연결하려면:

```yaml
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/my-app-role
```

## 문제 해결

### ALB 인그레스 문제

인그레스 상태 확인:
```bash
kubectl get ingress my-app-alb
kubectl describe ingress my-app-alb
```

### SSM Parameter Store 문제

파라미터 마운트 확인:
```bash
kubectl exec -it <pod-name> -- ls -la /mnt/secrets-store
```

### Route53 DNS 레코드 문제

DNS 레코드 확인:
```bash
aws route53 list-resource-record-sets --hosted-zone-id <zone-id> --query "ResourceRecordSets[?Name=='my-app.example.com.']"
```
