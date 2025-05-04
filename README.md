# AWS EKS Helm 차트

이 Helm 차트는 AWS EKS 클러스터에서 애플리케이션을 배포하기 위한 템플릿입니다. AWS Application Load Balancer를 통한 인그레스 관리를 지원합니다.

## 주요 기능

- **AWS EKS 최적화**: EKS 클러스터에서 실행되도록 최적화된 구성
- **인그레스 통합**: 다양한 인그레스 컨트롤러 지원 (ALB, Nginx, Traefik 등)
- **다중 환경 지원**: 개발, 스테이징, 프로덕션 환경에 맞는 구성 가능
- **ConfigMap 및 Secret 관리**: 다양한 구성 및 시크릿 관리 기능 제공
- **네트워크 정책**: Kubernetes NetworkPolicy를 통한 보안 강화
- **확장성**: HPA(Horizontal Pod Autoscaler)를 통한 자동 스케일링 기능

## 사전 요구사항

- Kubernetes 1.19+
- Helm 3.2.0+
- AWS EKS 클러스터
- 사용하는 인그레스 컨트롤러(선택):
  - AWS Load Balancer Controller
  - Nginx Ingress Controller
  - Traefik

## 설치

### 기본 설치

```bash
# 기본 설정으로 설치
helm install my-app . -n my-namespace

# 커스텀 values 파일로 설치
helm install my-app . -f values-prod.yaml -n my-namespace
```

### 설치 확인

```bash
# 배포 상태 확인
kubectl get all -l app.kubernetes.io/instance=my-app -n my-namespace
```

## 구성 옵션

| 매개변수 | 설명 | 기본값 |
|---------|-------------|---------|
| `replicaCount` | 배포할 레플리카 수 | `1` |
| `image.repository` | 컨테이너 이미지 저장소 | `nginx` |
| `image.tag` | 컨테이너 이미지 태그 | `""` (차트 appVersion 사용) |
| `image.pullPolicy` | 이미지 풀 정책 | `IfNotPresent` |
| `imagePullSecrets` | 이미지 풀 시크릿 | `[]` |
| `nameOverride` | 차트 이름 재정의 | `""` |
| `fullnameOverride` | 전체 이름 재정의 | `""` |
| `serviceAccount.create` | 서비스 계정 생성 여부 | `true` |
| `serviceAccount.annotations` | 서비스 계정 어노테이션 | `{}` |
| `serviceAccount.name` | 서비스 계정 이름 | `""` (생성되는 경우 자동 생성) |
| `aws.region` | AWS 리전 | `"us-east-1"` |
| `service.type` | 서비스 타입 | `ClusterIP` |
| `service.port` | 서비스 포트 | `80` |
| `ingress.enabled` | 인그레스 활성화 | `false` |
| `ingress.controllerType` | 인그레스 컨트롤러 타입(alb, nginx 등) | `""` |
| `ingress.annotations` | 인그레스 어노테이션 | `{}` |
| `networkPolicy.enabled` | 네트워크 정책 활성화 | `false` |

전체 구성 옵션은 [values.yaml](values.yaml) 파일을 참조하세요.

## AWS 서비스 연동 설정

이 차트는 다음과 같은 구조로 AWS 서비스 연동을 제공합니다:

1. **서비스 일반 설정**: `service`, `ingress` 등 쿠버네티스 리소스는 최상위 키로 설정
2. **AWS 특정 설정**: AWS 관련 공통 설정은 `aws` 키 아래 그룹화
   - `aws.region`: AWS 리전

### 인그레스 연동 예시

AWS ALB 인그레스를 사용하기 위한 설정 예시:

```yaml
# 인그레스 설정
ingress:
  enabled: true
  controllerType: "alb"
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTP
    alb.ingress.kubernetes.io/healthcheck-path: /health
    external-dns.alpha.kubernetes.io/hostname: app.example.com
  hosts:
    - host: app.example.com
      paths:
        - path: /
          pathType: Prefix
```

## 모듈 구성

차트는 다음 구성 요소로 구성됩니다:

- **메인 애플리케이션**: 기본 애플리케이션 배포
- **서비스**: 애플리케이션 액세스를 위한 Kubernetes 서비스
- **인그레스**: 외부 액세스 설정
- **네트워크 정책**: 애플리케이션의 네트워크 트래픽 제어
- **ConfigMap 및 Secret**: 애플리케이션 구성 및 보안 정보 관리

## 환경 별 구성

### 개발 환경

```yaml
replicaCount: 1
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

### 프로덕션 환경

```yaml
replicaCount: 3
resources:
  limits:
    cpu: 1
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

## 문제 해결

일반적인 문제 해결:

1. 포드가 시작되지 않는 경우: `kubectl describe pod <pod-name>` 명령으로 이벤트 확인
2. 인그레스 연결 문제: 해당 인그레스 컨트롤러 로그 확인

## 참고 자료

- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller)
- [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [Traefik](https://doc.traefik.io/traefik/providers/kubernetes-ingress/)
- [Helm 문서](https://helm.sh/docs/)
