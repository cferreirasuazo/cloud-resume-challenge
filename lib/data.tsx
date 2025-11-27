import { Github, Linkedin, Mail, Twitter } from "lucide-react"

export const DATA = {
  name: "Brittany Chiang",
  initials: "BC",
  location: "Boston, MA",
  locationLink: "https://www.google.com/maps/place/Boston,+MA",
  description: "Front End Engineer. I build accessible, pixel-perfect digital experiences for the web.",
  summary:
    "I'm a developer passionate about crafting accessible, pixel-perfect user interfaces that blend thoughtful design with robust engineering. My favorite work lies at the intersection of design and development, creating experiences that not only look great but are meticulously built for performance and usability.",
  avatarUrl: "/diverse-avatars.png",
  skills: ["React", "Next.js", "Typescript", "Node.js", "Python", "PostgreSQL", "Docker", "Kubernetes", "Java", "C++"],
  contact: {
    email: "hello@example.com",
    tel: "+123456789",
    social: {
      GitHub: {
        name: "GitHub",
        url: "https://github.com",
        icon: Github,
      },
      LinkedIn: {
        name: "LinkedIn",
        url: "https://linkedin.com",
        icon: Linkedin,
      },
      X: {
        name: "X",
        url: "https://x.com",
        icon: Twitter,
      },
      email: {
        name: "Send Email",
        url: "#",
        icon: Mail,
      },
    },
  },
  work: [
    {
      company: "Klaviyo",
      href: "https://klaviyo.com",
      badges: [],
      location: "Boston, MA",
      title: "Senior Frontend Engineer, Accessibility",
      logoUrl: "/klaviyo.jpg",
      start: "2024",
      end: "Present",
      description:
        "Build and maintain critical components used to construct Klaviyo's frontend, across the whole product. Work closely with cross-functional teams, including developers, designers, and product managers, to implement and advocate for best practices in web accessibility.",
    },
    {
      company: "Apple",
      href: "https://apple.com",
      badges: [],
      location: "Cupertino, CA",
      title: "UI Engineer",
      logoUrl: "/ripe-red-apple.png",
      start: "2021",
      end: "2024",
      description:
        "Developed and maintained critical components for Apple's internal tools. Collaborated with designers and other engineers to ensure high-quality, accessible user interfaces.",
    },
    {
      company: "Scout Studio",
      href: "https://scout.camd.northeastern.edu/",
      badges: [],
      location: "Boston, MA",
      title: "Developer",
      logoUrl: "/lone-scout.png",
      start: "2020",
      end: "2021",
      description:
        "Collaborated with other student designers and engineers on pro-bono projects to create new brands, design systems, and websites for organizations in the community.",
    },
  ],
  education: [
    {
      school: "Northeastern University",
      href: "https://northeastern.edu",
      degree: "Bachelor's Degree of Computer Science",
      logoUrl: "/northeastern.jpg",
      start: "2016",
      end: "2021",
    },
  ],
  projects: [
    {
      title: "Chat Collect",
      href: "https://chatcollect.com",
      dates: "Jan 2024 - Feb 2024",
      active: true,
      description:
        "With the release of the OpenAI GPT Store, I decided to build a SaaS which allows users to collect email addresses from their GPT users. This is a great way to build an audience and monetize your GPT API usage.",
      technologies: ["Next.js", "Typescript", "PostgreSQL", "Prisma", "TailwindCSS", "Stripe", "Shadcn UI", "Magic UI"],
      links: [
        {
          type: "Website",
          href: "https://chatcollect.com",
          icon: <div className="size-3" />,
        },
      ],
      image: "/abstract-geometric-project.png",
      video: "",
    },
    {
      title: "Magic UI",
      href: "https://magicui.design",
      dates: "June 2023 - Present",
      active: true,
      description: "Designed, developed and sold animated UI components for developers.",
      technologies: ["Next.js", "Typescript", "PostgreSQL", "Prisma", "TailwindCSS", "Stripe", "Shadcn UI", "Magic UI"],
      links: [
        {
          type: "Website",
          href: "https://magicui.design",
          icon: <div className="size-3" />,
        },
      ],
      image: "/abstract-geometric-structure.png",
      video: "",
    },
  ],
}
