---
title: "What is Kong?"
weight: 5
---

Kong Gateway is Kong’s API gateway with enterprise functionality. As part of Kong Konnect, the gateway brokers an organization’s information across all services by allowing customers to manage the full lifecycle of services and APIs. On top of that, it enables users to simplify the management of APIs and microservices across hybrid-cloud and multi-cloud deployments.

Kong Gateway is designed to run on decentralized architectures, leveraging workflow automation and modern GitOps practices. With Kong Gateway, users can:

* Decentralize applications/services and transition to microservices
* Create a thriving API developer ecosystem
* Proactively identify API-related anomalies and threats
* Secure and govern APIs/services, and improve API visibility across the entire organization

Kong Gateway is a combination of several features and modules built on top of the open-sourced Kong Gateway, as shown in the diagram and described in the next section, Kong Gateway Enterprise Features.

![introduction](/static/images/introduction.png)


## Kong Gateway Enterprise Features
Kong Gateway Enterprise features are described in this section, including modules and plugins that extend and enhance the functionality of the Kong Konnect platform.

### Kong Gateway (OSS)
Kong Gateway (OSS) is a lightweight, fast, and flexible cloud-native API gateway. It’s easy to download, install, and configure to get up and running once you know the basics. The gateway runs in front of any RESTful API and is extended through modules and plugins which provide extra functionality beyond the core platform.

### Kong Admin API
Kong Admin API provides a RESTful interface for administration and configuration of Services, Routes, Plugins, and Consumers. All of the tasks you perform in the Kong Manager can be automated using the Kong Admin API. For more information, see Kong Admin API.

### Kong Developer Portal
Kong Developer Portal (Kong Dev Portal) is used to onboard new developers and to generate API documentation, create custom pages, manage API versions, and secure developer access. For more information, see Kong Developer Portal.

### Kubernetes Ingress Controller
Kong for Kubernetes Enterprise (K4K8S) is a Kubernetes Ingress Controller. A Kubernetes Ingress Controller is a proxy that exposes Kubernetes services from applications (for example, Deployments, ReplicaSets) running on a Kubernetes cluster to client applications running outside of the cluster. The intent of an Ingress Controller is to provide a single point of control for all incoming traffic into the Kubernetes cluster. For more information, see Kong for Kubernetes.

### Kong Manager
Kong Manager is the Graphical User Interface (GUI) for Kong Gateway Enterprise. It uses the Kong Admin API under the hood to administer and control Kong Gateway (OSS). Use Kong Manager to organize teams, adjust policies, and monitor performance with just a few clicks. Group your teams, services, plugins, consumer management, and more exactly how you want them. Create new routes and services, activate or deactivate plugins in seconds. For more information, see the Kong Manager Guide.

### Kong Plugins
Kong Gateway plugins provide advanced functionality to better manage your API and microservices. With turnkey capabilities to meet the most challenging use cases, Kong Gateway Enterprise plugins ensure maximum control and minimizes unnecessary overhead. Enable features like authentication, rate-limiting, and transformations by enabling Kong Gateway Enterprise plugins through Kong Manager or the Admin API. For more information on which plugins are Enterprise-only, see the Kong Hub.

### Kong Vitals
Kong Vitals provides useful metrics about the health and performance of your Kong Gateway Enterprise nodes, as well as metrics about the usage of your gateway-proxied APIs. You can visually monitor vital signs and pinpoint anomalies in real-time, and use visual API analytics to see exactly how your APIs and Gateway are performing and access key statistics. Kong Vitals is part of the Kong Manager UI. For more information, see Kong Vitals.

### Insomnia
Insomnia enables spec-first development for all REST and GraphQL services. With Insomnia, organizations can accelerate design and test workflows using automated testing, direct Git sync, and inspection of all response types. Teams of all sizes can use Insomnia to increase development velocity, reduce deployment risk, and increase collaboration. For more information, see Insomnia documentation.



## Key Concepts and Terminology
Kong Gateway Enterprise uses common terms for entities and processes that have a specific meaning in context. This topic provides a conceptual overview of terms, and how they apply to Kong’s use cases.

### Admin
An Admin is a Kong Gateway user account capable of accessing the Admin API or Kong Manager. With RBAC and Workspaces, access can be modified and limited to specific entities.

### Authentication
Authentication is the process by which a system validates the identity of a user account. It is a separate concept from authorization.

API gateway authentication is an important way to control the data that is allowed to be transmitted to and from your APIs. An API may have a restricted list of identities that are authorized to access it. Authentication is the process of proving an identity.

### Authorization
Authorization is the system of defining access to certain resources. In Kong Gateway, Role-Based Access Control (RBAC) is the main authorization mode. To define authorization to an API, it is possible to use the ACL Plugin in conjunction with an authentication plugin.

### Client
A Kong Client refers to the downstream client making requests to Kong’s proxy port. It could be another service in a distributed application, a user’s identity, a user’s browser, or a specific device.

### Consumer
A Consumer object represents a client of a Service.

A Consumer is also the Admin API entity representing a developer or machine using the API. When using Kong, a Consumer only communicates with Kong which proxies every call to the said upstream API.

You can either rely on Kong as the primary datastore, or you can map the consumer list with your database to keep consistency between Kong and your existing primary datastore.

### Host
A Host represents the domain hosts (using DNS) intended to receive upstream traffic. In Kong, it is a list of domain names that match a Route object.

### Methods
Methods represent the HTTP methods available for requests. It accepts multiple values, for example, GET, POST, and DELETE. Its default value is empty (the HTTP method is not used for routing).

### Permission
A Permission is a policy representing the ability to create, read, update, or destroy an Admin API entity defined by endpoints.

### Plugin
Plugins provide advanced functionality and extend the use of Kong Gateway, allowing you to add new features to your gateway. Plugins can be configured to run in a variety of contexts, ranging from a specific route to all upstreams. Plugins can perform operations in your environment, such as authentication, rate-limiting, or transformations on a proxied request.

### Proxy
Kong is a reverse proxy that manages traffic between clients and hosts. As a gateway, Kong’s proxy functionality evaluates any incoming HTTP request against the Routes you have configured to find a matching one. If a given request matches the rules of a specific Route, Kong processes proxying the request. Because each Route is linked to a Service, Kong runs the plugins you have configured on your Route and its associated Service and then proxies the request upstream.

### Proxy Caching
One of the key benefits of using a reverse proxy is the ability to cache frequently-accessed content. The benefit is that upstream services do not need to waste computation on repeated requests.

One of the ways Kong delivers performance is through Proxy Caching, using the Proxy Cache Advanced Plugin. This plugin supports performance efficiency by providing the ability to cache responses based on requests, response codes and content type.

Kong receives a response from a service and stores it in the cache within a specific timeframe.

For future requests within the timeframe, Kong responds from the cache instead of the service.

The cache timeout is configurable. Once the time expires, Kong forwards the request to the upstream again, caches the result, and then responds from the cache until the next timeout.

The plugin can store cached data in-memory. The tradeoff is that it competes for memory with other processes, so for improved performance, use Redis for caching.

### Rate Limiting
Rate Limiting allows you to restrict how many requests your upstream services receive from your API consumers, or how often each user can call the API. Rate limiting protects the APIs from inadvertent or malicious overuse. Without rate limiting, each user may request as often as they like, which can lead to spikes of requests that starve other consumers. After rate limiting is enabled, API calls are limited to a fixed number of requests per second.

In this workflow, we are going to enable the Rate Limiting Advanced Plugin. This plugin provides support for the sliding window algorithm to prevent the API from being overloaded near the window boundaries and adds Redis support for greater performance.

### Role
A Role is a set of permissions that may be reused and assigned to Admins. For example, this diagram shows multiple admins assigned to a single shared role that defines permissions for a set of objects in a workspace.

### Route
A Route, also referred to as Route object, defines rules to match client requests to upstream services. Each Route is associated with a Service, and a Service may have multiple Routes associated with it. Routes are entry-points in Kong and define rules to match client requests. Once a Route is matched, Kong proxies the request to its associated Service. See the Proxy Reference for a detailed explanation of how Kong proxies traffic.

### Service
A Service, also referred to as a Service object, is the upstream APIs and microservices Kong manages. Examples of Services include a data transformation microservice, a billing API, and so on. The main attribute of a Service is its URL (where Kong should proxy traffic to), which can be set as a single string or by specifying its protocol, host, port and path individually. The URL can be composed by specifying a single string or by specifying its protocol, host, port, and path individually.

Before you can start making requests against a Service, you need to add a Route to it. Routes specify how (and if) requests are sent to their Services after they reach Kong. A single Service can have many Routes. After configuring the Service and the Route, you’ll be able to make requests through Kong using them.

### Super Admin
A Super Admin, or any Role with read and write access to the /admins and /rbac endpoints, creates new Roles and customize Permissions. A Super Admin can:

* Invite and disable other Admin accounts
* Assign and revoke Roles to Admins
* Create new Roles with custom Permissions
* Create new Workspaces

### Tags
Tags are customer defined labels that let you manage, search for, and filter core entities using the ?tags querystring parameter. Each tag must be composed of one or more alphanumeric characters, \_\, -, . or ~. Most core entities can be tagged via their tags attribute, upon creation or edition.

### Teams
Teams organize developers into working groups, implements policies across entire environments, and onboards new users while ensuring compliance. Role-Based Access Control (RBAC) and Workspaces allow users to assign administrative privileges and grant or limit access privileges to individual users and consumers, entire teams, and environments across the Kong platform.

### Upstream
An Upstream object refers to your upstream API/service sitting behind Kong, to which client requests are forwarded. An Upstream object represents a virtual hostname and can be used to load balance incoming requests over multiple services (targets). For example, an Upstream named service.v1.xyz for a Service object whose host is service.v1.xyz. Requests for this Service object would be proxied to the targets defined within the upstream.

### Workspaces
Workspaces enable an organization to segment objects and admins into namespaces. The segmentation allows teams of admins sharing the same Kong cluster to adopt roles for interacting with specific objects. For example, one team (Team A) may be responsible for managing a particular service, whereas another team (Team B) may be responsible for managing another service.

Many organizations have strict security requirements. For example, organizations need the ability to segregate the duties of an administrator to ensure that a mistake or malicious act by one administrator does not cause an outage.





## Try Kong Gateway Enterprise
Kong Gateway is available in free mode. Download it and start testing out Gateway’s open source features with Kong Manager today.

Kong Gateway is also bundled with Kong Konnect. There are a few ways to test out the gateway’s Plus or Enterprise features:

Sign up for a free trial of [Kong Konnect Plus](https://cloud.konghq.com/register).
Try out Kong Gateway on Kubernetes using a live tutorial at [Kong for Kubernetes](https://education.konghq.com/courses/course-v1:kong+KGLL-108+Perpetual/about).
If you are interested in evaluating Enterprise features locally, the Kong sales team manages evaluation licenses as part of a formal sales process. The best way to get started with the sales process is to request a demo and indicate your interest.




