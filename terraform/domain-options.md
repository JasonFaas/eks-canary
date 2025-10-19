# Domain Options for Route53 Testing

## Option 1: AWS Test Domains (FREE - Recommended for Testing)

AWS provides several test domains that are free to use for development:

### Available Test Domains:
- `example.com` - Most commonly used
- `test.com` - Alternative option
- `example.org` - Another option

### Usage:
```hcl
domain_name = "example.com"
subdomain = "myapp"  # Creates: myapp.example.com
```

**Pros:**
- ✅ Completely free
- ✅ No domain purchase required
- ✅ Perfect for testing and development
- ✅ Works immediately

**Cons:**
- ❌ Not suitable for production (users won't trust example.com)
- ❌ Limited to testing/development use

## Option 2: Free Subdomains (FREE)

You can get free subdomains from various providers:

### Freenom (Free TLDs):
- `.tk`, `.ml`, `.ga`, `.cf` domains
- Examples: `myapp.tk`, `testapp.ml`

### DuckDNS (Free Subdomains):
- Get subdomains like `myapp.duckdns.org`
- Free and reliable for testing

### Usage:
```hcl
domain_name = "myapp.tk"  # or "myapp.duckdns.org"
subdomain = "canary"      # Creates: canary.myapp.tk
```

## Option 3: Use Existing Domain Subdomain (FREE if you own a domain)

If you have any domain (personal, work, etc.), create a subdomain:

### Examples:
- If you own `johndoe.com`, use `eks.johndoe.com`
- If you own `mycompany.com`, use `test.mycompany.com`

### Usage:
```hcl
domain_name = "johndoe.com"
subdomain = "eks"  # Creates: eks.johndoe.com
```

## Option 4: Buy a Cheap Domain (~$1-10/year)

For production use or if you want a "real" domain:

### Cheap Domain Providers:
- **Namecheap**: Often has $0.99 domains
- **GoDaddy**: Regular sales on domains
- **Cloudflare Registrar**: Cost price domains
- **Porkbun**: Competitive pricing

### Popular Cheap TLDs:
- `.xyz` - Often $1-2/year
- `.top` - Usually $1-3/year
- `.site` - Around $2-5/year

## Option 5: Use Route53 Hosted Zone with External Domain

If you have a domain registered elsewhere but want to use Route53:

1. Keep your domain registered with your current provider
2. Use Route53 as your DNS provider
3. Update your domain's nameservers to point to Route53

### Usage:
```hcl
use_existing_zone = true
existing_zone_id = "Z1234567890ABCDEF"  # Your existing Route53 zone
```

## Recommended Approach for Your Use Case

For **testing and development**:
```hcl
# In terraform.tfvars
domain_name = "example.com"
subdomain = "myapp"
```

This creates: `myapp.example.com` - completely free and works immediately!

For **production**:
- Buy a cheap domain ($1-10/year)
- Use a professional subdomain like `app.yourdomain.com`

## Cost Breakdown

| Option | Cost | Setup Time | Production Ready |
|--------|------|------------|------------------|
| AWS Test Domain | FREE | Immediate | ❌ No |
| Free Subdomain | FREE | 5 minutes | ⚠️ Limited |
| Existing Domain Subdomain | FREE | Immediate | ✅ Yes |
| Cheap Domain | $1-10/year | 10 minutes | ✅ Yes |

## Quick Start (Recommended)

For immediate testing, use this configuration:

```hcl
# terraform.tfvars
domain_name = "example.com"
subdomain = "myapp"
blue_weight = 90
green_weight = 10
use_existing_zone = false
```

This will create `myapp.example.com` with weighted routing to your load balancers - completely free and ready to test!
