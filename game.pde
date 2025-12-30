ArrayList<Particle> particles = new ArrayList<Particle>();
PVector blackHole;
float bhMass = 500; // Масса центральной черной дыры

void setup() {
  size(1000, 800);
  background(0);
  blackHole = new PVector(width/2, height/2);
}

void draw() {
  // Эффект затухания шлейфа
  fill(0, 30);
  noStroke();
  rect(0, 0, width, height);
  
  // Рисуем черную дыру (просто визуальный маркер)
  fill(50, 0, 100);
  ellipse(blackHole.x, blackHole.y, 10, 10);

  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.applyGravity(blackHole, bhMass); // Тяга к центру
    p.update(particles);
    p.display();
    
    // Удаляем, если улетела слишком далеко
    if (p.pos.dist(blackHole) > 2000) {
      particles.remove(i);
    }
  }
}

void mousePressed() {
  particles.add(new Particle(mouseX, mouseY, new PVector(random(-2, 2), random(-2, 2))));
}

class Particle {
  PVector pos, vel, acc;
  float mass;
  float radius;

  Particle(float x, float y, PVector v) {
    pos = new PVector(x, y);
    vel = v;
    acc = new PVector(0, 0);
    mass = random(2, 5);
    radius = mass * 2;
  }

  void applyGravity(PVector target, float m) {
    PVector force = PVector.sub(target, pos);
    float d = constrain(force.mag(), 10, 500);
    force.normalize();
    float strength = (0.5 * m * mass) / (d * d);
    force.mult(strength);
    acc.add(force);
  }

  void update(ArrayList<Particle> others) {
    // Гравитация между частицами и СЛИЯНИЕ
    for (int i = others.size() - 1; i >= 0; i--) {
      Particle other = others.get(i);
      if (other != this) {
        float d = pos.dist(other.pos);
        
        // Проверка столкновения (слияние)
        if (d < (radius + other.radius) * 0.5) {
          // Закон сохранения импульса: (m1*v1 + m2*v2) / (m1+m2)
          PVector newVel = PVector.add(PVector.mult(vel, mass), PVector.mult(other.vel, other.mass));
          newVel.div(mass + other.mass);
          vel = newVel;
          
          mass += other.mass;
          radius = mass * 2;
          others.remove(i);
        } else {
          applyGravity(other.pos, other.mass);
        }
      }
    }

    vel.add(acc);
    pos.add(vel);
    acc.mult(0);
  }

  void display() {
    float speed = vel.mag();
    // Цветовая палитра: синий (медленно) -> красный (быстро)
    // map(значение, мин_вход, макс_вход, мин_выход, макс_выход)
    float r = map(speed, 0, 10, 50, 255);
    float b = map(speed, 0, 10, 255, 50);
    
    fill(r, 100, b);
    noStroke();
    ellipse(pos.x, pos.y, radius, radius);
  }
}
