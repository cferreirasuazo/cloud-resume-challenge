"use client"
import { ProjectCard } from "@/components/project-card"
import { ResumeCard } from "@/components/resume-card"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { DATA } from "@/lib/data"
import { motion } from "framer-motion"
import Link from "next/link"

// Simple blur-in animation for sections
const blurIn = {
  hidden: { filter: "blur(10px)", opacity: 0, y: 20 },
  visible: { filter: "blur(0px)", opacity: 1, y: 0, transition: { duration: 0.8, ease: "easeOut" } },
}

export default function Page() {
  return (
    <main className="flex min-h-screen flex-col items-center bg-[#0a192f] text-slate-300 font-sans selection:bg-teal-300 selection:text-slate-900">
      <div className="w-full max-w-3xl space-y-24 px-6 py-12 sm:py-24">
        {/* HERO */}
        <motion.section
          id="hero"
          initial="hidden"
          animate="visible"
          variants={blurIn}
          className="mx-auto w-full max-w-2xl space-y-8"
        >
          <div className="flex flex-col-reverse gap-8 sm:flex-row sm:items-center sm:justify-between">
            <div className="flex flex-col gap-4 text-left">
              <h1 className="font-bold text-4xl tracking-tighter sm:text-5xl xl:text-6xl/none text-slate-100">
                Hi, I'm {DATA.name.split(" ")[0]} 👋
              </h1>
              <h2 className="text-xl font-medium text-teal-300">{DATA.description}</h2>
              <p className="max-w-[600px] text-base text-slate-400 md:text-lg leading-relaxed">{DATA.summary}</p>
              <div className="flex gap-4 mt-2">
                {Object.entries(DATA.contact.social).map(([key, value]) => (
                  <Link key={key} href={value.url} className="text-slate-400 hover:text-teal-300 transition-colors">
                    <value.icon className="size-6" />
                    <span className="sr-only">{value.name}</span>
                  </Link>
                ))}
              </div>
            </div>
            <Avatar className="size-32 border-2 border-teal-300/20 shadow-xl">
              <AvatarImage alt={DATA.name} src={DATA.avatarUrl || "/placeholder.svg"} />
              <AvatarFallback>{DATA.initials}</AvatarFallback>
            </Avatar>
          </div>
        </motion.section>

        {/* ABOUT - Keeping it minimal as requested, merging into Hero mostly, but good to have dedicated text if needed */}

        {/* WORK EXPERIENCE */}
        <motion.section
          id="work"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={blurIn}
          className="flex flex-col gap-y-6"
        >
          <div className="flex flex-col items-start gap-2">
            <h2 className="text-2xl font-bold tracking-tighter sm:text-3xl text-slate-100 flex items-center gap-2">
              <span className="text-teal-300 text-xl font-mono">01.</span> Work Experience
            </h2>
            <div className="w-full h-px bg-slate-800 my-4" />
          </div>
          {DATA.work.map((work, id) => (
            <ResumeCard
              key={work.company}
              logoUrl={work.logoUrl}
              altText={work.company}
              title={work.company}
              subtitle={work.title}
              href={work.href}
              badges={work.badges}
              period={`${work.start} - ${work.end ?? "Present"}`}
              description={work.description}
            />
          ))}
        </motion.section>

        {/* EDUCATION */}
        <motion.section
          id="education"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={blurIn}
          className="flex flex-col gap-y-6"
        >
          <div className="flex flex-col items-start gap-2">
            <h2 className="text-2xl font-bold tracking-tighter sm:text-3xl text-slate-100 flex items-center gap-2">
              <span className="text-teal-300 text-xl font-mono">02.</span> Education
            </h2>
            <div className="w-full h-px bg-slate-800 my-4" />
          </div>
          {DATA.education.map((education, id) => (
            <ResumeCard
              key={education.school}
              href={education.href}
              logoUrl={education.logoUrl}
              altText={education.school}
              title={education.school}
              subtitle={education.degree}
              period={`${education.start} - ${education.end}`}
            />
          ))}
        </motion.section>

        {/* SKILLS */}
        <motion.section
          id="skills"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={blurIn}
          className="flex flex-col gap-y-6"
        >
          <div className="flex flex-col items-start gap-2">
            <h2 className="text-2xl font-bold tracking-tighter sm:text-3xl text-slate-100 flex items-center gap-2">
              <span className="text-teal-300 text-xl font-mono">03.</span> Skills
            </h2>
            <div className="w-full h-px bg-slate-800 my-4" />
          </div>
          <div className="flex flex-wrap gap-2">
            {DATA.skills.map((skill, id) => (
              <Badge
                key={skill}
                className="bg-slate-800 text-teal-300 hover:bg-slate-700 px-3 py-1 text-sm border-teal-900/50 transition-all"
              >
                {skill}
              </Badge>
            ))}
          </div>
        </motion.section>

        {/* PROJECTS */}
        <motion.section
          id="projects"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={blurIn}
          className="flex flex-col gap-y-6"
        >
          <div className="flex flex-col items-start gap-2">
            <h2 className="text-2xl font-bold tracking-tighter sm:text-3xl text-slate-100 flex items-center gap-2">
              <span className="text-teal-300 text-xl font-mono">04.</span> Featured Projects
            </h2>
            <div className="w-full h-px bg-slate-800 my-4" />
          </div>
          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-2">
            {DATA.projects.map((project, id) => (
              <ProjectCard
                key={project.title}
                href={project.href}
                title={project.title}
                description={project.description}
                dates={project.dates}
                tags={project.technologies}
                image={project.image}
                video={project.video}
                links={project.links}
              />
            ))}
          </div>
        </motion.section>

        {/* CONTACT */}
        <motion.section
          id="contact"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={blurIn}
          className="flex flex-col items-center justify-center gap-4 text-center py-12"
        >
          <div className="space-y-3">
            <div className="inline-block rounded-lg bg-slate-800 px-3 py-1 text-sm text-teal-300">What's Next?</div>
            <h2 className="text-3xl font-bold tracking-tighter sm:text-5xl text-slate-100">Get in Touch</h2>
            <p className="mx-auto max-w-[600px] text-slate-400 md:text-xl/relaxed lg:text-base/relaxed xl:text-xl/relaxed">
              I'm currently looking for new opportunities. Whether you have a question or just want to say hi, I'll try
              my best to get back to you!
            </p>
          </div>
          <Link
            href={`mailto:${DATA.contact.email}`}
            className="mt-8 inline-flex items-center justify-center rounded-md border border-teal-300 bg-transparent px-8 py-3 text-sm font-medium text-teal-300 shadow-sm transition-colors hover:bg-teal-300/10 focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-teal-300"
          >
            Say Hello
          </Link>
        </motion.section>

        <footer className="w-full py-6 text-center text-sm text-slate-600">
          <p>Designed & Built by {DATA.name}</p>
        </footer>
      </div>
    </main>
  )
}
